# Testing Strategy

Use this file when the repo already has meaningful test infrastructure, uses a real database in tests, or the user explicitly wants a deeper review of test design.

The goal is not just “tests exist.” The goal is fast, isolated, trustworthy tests that work with real infrastructure where it matters.

## What good looks like

Prefer a layered strategy:

- unit and integration tests on Vitest
- e2e tests on Playwright
- real database tests when database behavior is part of correctness
- parallel execution without shared mutable state

If the repo mocks the database heavily, do not automatically call that wrong. But if the product logic depends on SQL constraints, transactions, Prisma queries, or auth/session persistence, prefer real-database coverage for those paths.

## Real DB integration tests with Testcontainers

When the repo uses Prisma and PostgreSQL, a strong pattern is:

1. Start a disposable database container per suite or worker.
2. Bind Postgres to a dynamic host port.
3. Generate a per-run `DATABASE_URL`.
4. Run schema setup against that URL.
5. Instantiate `PrismaClient` with the overridden datasource URL.
6. Truncate between tests.
7. Tear everything down after the suite finishes.

### Port collision avoidance

If `compose.yml` is reused for tests, prefer making the database port overrideable:

```yaml
services:
  db:
    image: postgres:17
    ports:
      - ${DATABASE_PORT:-5432}:5432
    environment:
      - POSTGRES_USER=${DATABASE_USER}
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}
      - POSTGRES_DB=${DATABASE_DB}
```

This allows normal development to keep `5432`, while tests can inject `DATABASE_PORT=0` or another dynamic port.

### DB setup helper

Prefer a shared helper rather than duplicating setup in every suite.

Representative shape:

```ts
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { Prisma, PrismaClient } from '@prisma/client';
import { DockerComposeEnvironment, Wait } from 'testcontainers';
import { createDBUrl } from '../src/app/_utils/db';

const execAsync = promisify(exec);

export async function setupDB({ port }: { port: 'random' | number }) {
	const container = await new DockerComposeEnvironment('.', 'compose.yml')
		.withEnvironmentFile('.env.test')
		.withEnvironment({
			DATABASE_PORT: port === 'random' ? '0' : `${port}`,
		})
		.withWaitStrategy('db', Wait.forListeningPorts())
		.up(['db']);

	const dbContainer = container.getContainer('db-1');
	const mappedPort = dbContainer.getMappedPort(5432);
	const url = createDBUrl({
		host: dbContainer.getHost(),
		port: mappedPort,
	});

	await execAsync(`DATABASE_URL=${url} npx prisma db push`);

	const prisma = new PrismaClient({
		datasources: {
			db: {
				url,
			},
		},
	});

	async function down() {
		await prisma.$disconnect();
		await container.down();
	}

	return <const>{
		container,
		port: mappedPort,
		url,
		prisma,
		truncate: () => truncate(prisma),
		down,
		async [Symbol.asyncDispose]() {
			await down();
		},
	};
}

export async function truncate(prisma: PrismaClient) {
	const tableNames = Prisma.dmmf.datamodel.models.map((model) => {
		return model.dbName || model.name.toLowerCase();
	});
	const truncateQuery = `TRUNCATE TABLE ${tableNames.map((name) => `"${name}"`).join(', ')} CASCADE`;

	await prisma.$executeRawUnsafe(truncateQuery);
}
```

### What to check

- Compose or container setup supports dynamic port assignment.
- Prisma datasource URL is overridden at client creation time.
- Schema setup runs against the dynamically created DB, not the developer DB.
- Cleanup is automatic.
- `truncate` is centralized and not copy-pasted across suites.

## Vitest pattern

For Vitest, prefer one helper that:

- hoists DB setup before imports that depend on Prisma
- mocks the app’s Prisma client to the isolated test client
- truncates after each test
- shuts down after all tests

Representative shape:

```ts
import { afterAll, afterEach, vi } from 'vitest';

export async function setup() {
	const { prisma, truncate, down } = await vi.hoisted(async () => {
		const { setupDB } = await import('../../../tests/db.setup');
		return await setupDB({ port: 'random' });
	});

	vi.mock('../_clients/prisma', () => ({
		prisma,
	}));

	afterAll(async () => {
		await down();
	});

	afterEach(async () => {
		await truncate();
	});

	return <const>{
		prisma,
		truncate,
		down,
	};
}
```

### What to check

- `vi.hoisted` is used when import timing requires it.
- The test client replaces the production Prisma client cleanly.
- Per-test cleanup is `truncate`, not full process restart.
- Each suite has isolated DB state.

## Parallel Playwright with real DB

Playwright becomes slower and harder to isolate if every test hits the same app process and database.

A stronger pattern is:

1. Prepare authentication bypass for test mode when the real auth flow is impractical.
2. Pre-generate authenticated `storageState` files for test users.
3. Start one DB container per worker.
4. Start one app process per worker on its own port.
5. Reset DB and browser state after each test.
6. Tear down DB and app when the worker finishes.

### Test-mode auth

If the app uses NextAuth and OAuth is painful in e2e, a test-only JWT override can be reasonable:

```ts
export const config = {
	providers: [],
	callbacks: {
		session: ({ session }) => session,
	},
	...(process.env.NEXTAUTH_TEST_MODE === 'true' ? configForTest : {}),
};
```

This must be clearly test-only. Flag any version that could leak into production behavior.

### App startup per worker

Representative shape:

```ts
import { exec } from 'node:child_process';
import { getRandomPort } from './getRandomPort';
import { waitForHealth } from './waitForHealth';

export async function setupApp(dbPort: number) {
	const appPort = await getRandomPort();
	const baseURL = `http://localhost:${appPort}`;
	const cp = exec(`NEXTAUTH_URL=${baseURL} DATABASE_PORT=${dbPort} pnpm start --port ${appPort}`);
	await waitForHealth(baseURL);

	return {
		appPort,
		baseURL,
		async [Symbol.asyncDispose]() {
			if (cp.pid) process.kill(cp.pid);
		},
	} as const;
}
```

### Worker-scoped fixtures

Prefer Playwright fixtures that own DB and app lifecycle per worker:

```ts
import { test as base } from '@playwright/test';
import { setupDB } from '../tests/db.setup';
import { setupApp } from './helpers/app';

export const test = base.extend({
	setup: [
		async ({ browser }, use) => {
			await using dbSetup = await setupDB({ port: 'random' });
			await using appSetup = await setupApp(dbSetup.port);
			const baseURL = appSetup.baseURL;
			const originalNewContext = browser.newContext.bind(browser);

			browser.newContext = async () => {
				return originalNewContext({ baseURL });
			};

			await use({
				prisma: dbSetup.prisma,
				appPort: appSetup.appPort,
				baseURL,
				dbURL: dbSetup.url,
			});
		},
		{
			scope: 'worker',
			auto: true,
		},
	],
});
```

### What to check

- The app is not shared across all workers on one fixed port.
- The DB is not shared across all workers.
- `baseURL` is worker-local.
- Health checks exist before tests start.
- Teardown happens even on failure.

## Authenticated user setup

If the suite uses authenticated users, prefer:

- prebuilt `storageState` files
- helpers that register users directly into the isolated DB
- per-test reset of DB state and cookies

This avoids repeating UI login flows and keeps e2e throughput high.

## Red flags

Mark these as `Missing` or `P1/P0` depending on severity:

- tests use a shared developer database
- fixed DB port with parallel workers
- fixed app port with parallel workers
- no cleanup between tests
- schema setup runs against the wrong database
- auth bypass is not gated tightly to test mode
- Prisma client still points at the default datasource
- container/app teardown is manual or flaky

## Reporting guidance

When reviewing a repo, summarize testing with these questions:

- Are unit/integration/e2e layers clearly separated?
- Does real DB testing exist where it matters?
- Can Vitest run in parallel safely?
- Can Playwright run in parallel safely?
- Is auth setup pragmatic but still contained to test mode?
- Are setup, reset, and teardown centralized in reusable helpers?

Keep the final report short. The detailed mechanics should stay in this file, not in `SKILL.md`.
