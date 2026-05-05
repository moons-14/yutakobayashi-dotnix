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

When the repo uses PostgreSQL with a real application database layer, a strong pattern is:

1. Start a disposable database container per suite or worker.
2. Bind Postgres to a dynamic host port.
3. Generate a per-run `DATABASE_URL`.
4. Run schema setup against that URL.
5. Instantiate the database client against the overridden URL.
6. Truncate between tests.
7. Tear everything down after the suite finishes.

### Port collision avoidance

If `compose.yml` is reused for tests, prefer making the database port overrideable:

```yaml
volumes:
  db-data:

services:
  db:
    image: postgres:17
    ports:
      - ${DATABASE_PORT:-5432}:5432
    environment:
      - POSTGRES_USER=${DATABASE_USER}
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}
      - POSTGRES_DB=${DATABASE_DB}
    # https://admin.alyfoods.com/blog/testcontainers-volume-mount-failure-debugging
    # volumes:
    #   - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready']
      interval: 1s
      timeout: 5s
      retries: 10
```

This allows normal development to keep `5432`, while tests can inject `DATABASE_PORT=0` or another dynamic port.

Prefer keeping the persistent volume commented out or otherwise disabled for the Testcontainers path when volume mounts are known to cause instability in disposable test environments.

The healthcheck matters because it gives the app and test harness a stronger readiness signal than “container started.”

### DB setup helper

Prefer a shared helper rather than duplicating setup in every suite.

Also prefer centralizing database URL construction in one helper instead of rebuilding connection strings ad hoc across tests and app code.

Representative shape:

```ts
export function createDBUrl({
	user = process.env.DATABASE_USER,
	password = process.env.DATABASE_PASSWORD,
	host = process.env.DATABASE_HOST,
	port = Number(process.env.DATABASE_PORT),
	db = process.env.DATABASE_DB,
	schema = process.env.DATABASE_SCHEMA,
}: {
	user?: string;
	password?: string;
	host?: string;
	port?: number;
	db?: string;
	schema?: string;
}) {
	return `postgresql://${user}:${password}@${host}:${port}/${db}?schema=${schema}`;
}
```

### What to check

- Compose or container setup supports dynamic port assignment.
- `healthcheck` exists and the test setup waits for actual readiness.
- DB URL construction is centralized instead of duplicated.
- The database client is created from the dynamic URL, not a default local URL.
- Schema setup runs against the dynamically created DB, not the developer DB.
- Cleanup is automatic.
- `truncate` is centralized and not copy-pasted across suites.

## Drizzle variant

If the repo uses Drizzle instead of Prisma, the same isolation pattern still applies:

1. start a disposable Postgres container
2. build a dynamic DB URL
3. run schema setup against that URL
4. construct a DB client against that URL
5. reset state between tests
6. tear everything down cleanly

Representative shape for a non-monorepo project:

```ts
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { type NodePgDatabase, drizzle } from 'drizzle-orm/node-postgres';
import { reset } from 'drizzle-seed';
import { Pool } from 'pg';
import { DockerComposeEnvironment, Wait } from 'testcontainers';
import * as schema from './schema';
import { createDBUrl } from '@/utils/db';

const execAsync = promisify(exec);

export type Database = NodePgDatabase<typeof schema>;

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

	await execAsync(`DATABASE_URL=${url} drizzle-kit push`);

	const pool = new Pool({ connectionString: url });
	const db = drizzle(pool, { schema });

	async function down() {
		await pool.end();
		await container.down();
	}

	return {
		url,
		container,
		port: mappedPort,
		db,
		truncate: () => truncate(db),
		down,
		async [Symbol.asyncDispose]() {
			await down();
		},
	} as const;
}

async function truncate(db: Database) {
	await reset(db, schema);
}
```

### What to check

- `drizzle-kit push` or the project's equivalent schema command runs against the dynamic `DATABASE_URL`
- `Pool` is created from the dynamic URL, not a default local URL
- `drizzle(...)` is built once per isolated DB instance
- cleanup closes the PG pool and tears down the container
- reset uses a centralized helper such as `drizzle-seed` `reset`

### Helper tests

If helpers like `createDBUrl` exist, prefer testing them directly.

Representative shape:

```ts
import { describe, expect, test } from 'vitest';
import { createDBUrl } from './db';

describe('utils/db', () => {
	describe('createDBUrl', () => {
		test('should create url by environment variables', () => {
			expect(createDBUrl({})).toMatchInlineSnapshot(
				`"postgresql://local:1234@localhost:5432/local?schema=public"`,
			);
		});

		test('should create url by params', () => {
			expect(
				createDBUrl({
					user: 'user',
					password: 'password',
					host: 'host',
					port: 5432,
					db: 'db',
					schema: 'schema',
				}),
			).toMatchInlineSnapshot(`"postgresql://user:password@host:5432/db?schema=schema"`);
		});
	});
});
```

This is small, but it matters. If the project relies on dynamic DB URLs for test isolation, bugs in that helper can invalidate the whole setup.

## Vitest pattern

For Vitest, prefer one helper that:

- hoists DB setup before imports that depend on Prisma
- mocks the app’s database client to the isolated test client
- truncates after each test
- shuts down after all tests

Representative shape:

```ts
import { afterAll, afterEach, vi } from 'vitest';

export async function setup() {
	const { db, truncate, down } = await vi.hoisted(async () => {
		const { setupDB } = await import('../../../tests/db.setup');
		return await setupDB({ port: 'random' });
	});

	vi.mock('../_clients/db', () => ({
		db,
	}));

	afterAll(async () => {
		await down();
	});

	afterEach(async () => {
		await truncate();
	});

	return {
		db,
		truncate,
		down,
	} as const;
}
```

### What to check

- `vi.hoisted` is used when import timing requires it.
- The test client replaces the production database client cleanly.
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
