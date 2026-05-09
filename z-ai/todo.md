# Add Raspberry Pi 5 NixOS Host

- [x] Confirm the intended Pi 5 migration shape and target hostname
- [x] Add the `pi5` NixOS host, including flake wiring and Pi-specific modules
- [x] Add a minimal server-oriented profile for the new host
- [x] Update repo docs and verify the new configuration evaluates

# Add Luanti

- [ ] Inspect the current shared package layout and confirm whether `luanti` should be common or OS-specific
- [ ] Add `luanti` to the minimal package list location
- [ ] Verify evaluation on both Darwin and Linux package sets and record doc impact

# Add Actrun Flake Output

- [ ] Inspect the current `actrun` integration in `flake.nix` and choose the minimal source-of-truth path
- [ ] Update flake inputs/overlays so `actrun` comes from the requested flake input
- [ ] Expose `actrun` in top-level flake packages and the default dev shell
- [ ] Verify flake evaluation and record doc impact

# Switch Codex Config To Writable Copy

- [x] Replace the `mkOutOfStoreSymlink` for `codex/config.toml` with a generated copy in `home.activation`
- [x] Restore the Codex TOML contents from the existing `codex/config.toml`
- [x] Verify the module evaluates cleanly and record doc impact

## Review

- Added a dedicated `pi5` NixOS host entry to the flake and kept the configuration headless and SSH-focused.
- Split the Pi5 host off from the heavier Linux desktop/server profiles so the new machine does not inherit unrelated GUI or desktop packages.
- Updated repository docs and architecture notes to mention the new Pi5 target.
- Verified `nix eval .#nixosConfigurations.pi5.config.system.build.toplevel.drvPath` resolves successfully.
- Verified `nix eval .#packages.aarch64-linux.roots.pname` still resolves after adding `aarch64-linux` to the flake systems list.

## Review

- Replaced the live `codex/config.toml` symlink with a `home.activation.writeCodexConfig` step that copies a Nix-generated TOML file into `~/.config/codex/config.toml` and sets it to `0644`.
- Kept `codex/config.toml` in the repo as the source content by reading it through `builtins.fromTOML` and re-emitting it with `pkgs.formats.toml`.
- Left `codex/AGENTS.md` on the existing out-of-store symlink because the request only covered `config.toml`.
- Verified the module evaluates in isolation with Home Manager's `lib.hm.dag` and a minimal fake package set.
- Doc impact: none. No `README.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/` updates are needed for this storage change.

# Review nextjs-onboarding Skill

- [x] Inspect `agents/skills/nextjs-onboarding/SKILL.md` and its references
- [x] Verify time-sensitive or version-sensitive guidance against official docs where needed
- [x] Record prioritized review findings and doc impact

## Review

- Reviewed `agents/skills/nextjs-onboarding/SKILL.md` plus `references/dependencies.md`, `references/testing.md`, and `references/utils.md`.
- Verified the version-sensitive points against current official docs for Next.js, pnpm, Zod, and MDN where the skill makes concrete claims.
- Doc impact: none. This task is a review only; no repository docs need updates unless the skill itself is revised later.

# Add Gip Function

- [x] Add a `gip` zsh function matching the requested public IP lookup behavior
- [x] Update the zsh functions README entry
- [x] Verify shell syntax and record review results

## Review

- Added `zsh/functions/gip.zsh` with a simple `curl -s http://ipecho.net/plain` lookup followed by `echo` to keep the output newline.
- Updated `zsh/functions/README.md` to list `gip`.
- Verified shell syntax with `zsh -n zsh/functions/gip.zsh`.
- Doc impact: no additional docs needed beyond the zsh functions README entry.

# Remove Peco From Nix

- [x] Find where `peco` is included in Nix modules and docs
- [x] Remove `peco` from the package set and update stale references if needed
- [x] Verify no relevant `peco` references remain and record review results

## Review

- Removed `peco` from the shared Home Manager package list in `nix/modules/home/packages.nix`.
- Repository search confirmed there are no remaining relevant `peco` references in `nix/`, `zsh/`, `README.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/`.
- Doc impact: none. No user-facing command or architecture docs required changes for this package removal.

# Add Ctrl+G Ghq Roots Picker

- [x] Inspect the current `g` shell function and zsh widget loading pattern
- [x] Replace the no-arg `g` picker with a shared `ghq` + `roots` + `fzf` implementation
- [x] Expose the same picker as a `Ctrl+G` zle widget and verify zsh syntax
- [x] Update any impacted docs and record review results

## Review

- Replaced the no-argument `g` picker in `zsh/functions/g.zsh` from `ghq + peco` to a shared `__ghq_roots_pick` helper built on `ghq list --full-path`, `roots`, and `fzf`.
- Added a fallback path that skips `roots` when the command is unavailable, matching the requested snippet behavior without extra branching elsewhere.
- Added `__ghq_roots_widget` plus `zle -N` and `bindkey '^G'` so the same picker can be opened directly with `Ctrl+G`.
- Updated `zsh/functions/README.md` and `AGENTS.md` to reflect the new `g` behavior and the new keybinding.
- Verified shell syntax with `zsh -n zsh/functions/g.zsh`.
- Verified in an interactive zsh that `g` resolves to the updated function body and `bindkey "^G"` reports `__ghq_roots_widget`.
- Interactive verification emitted sandbox-related warnings from unrelated writes under `$HOME` (`.zcompdump`, oh-my-zsh cache, `zsh-abbr` persistence), but the `g` function and `^G` binding still loaded successfully.

# Fix Darwin Activation Script

# Rename linear-linear To linear In Darwin Packages

- [x] Update the darwin brew-nix cask reference from `linear-linear` to `linear`
- [x] Verify the `pkgs.brewCasks.linear` attribute resolves in this flake context
- [x] Record review results and doc impact

## Review

- Updated `nix/modules/darwin/packages.nix` to use `linear` instead of `linear-linear` in the `pkgs.brewCasks` list.
- Verified `pkgs.brewCasks.linear.name` resolves in the current flake context with `nix eval --impure --expr`, which returned `"linear-1.28.13-260318pho1bttxr"`.
- Verified `darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.home.packages` now evaluates past the previous undefined-variable failure and contains the Linear package; the final membership check returned `true`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package-name correction.

# Add roots From nur-packages

- [x] Confirm how `roots` is exposed from `../nur-packages` and where `dotnix` should surface it
- [x] Add `roots` to the appropriate `dotnix` package lists/exports with minimal changes
- [x] Verify evaluation for both the flake package output and the user package set, then record doc impact

## Review

- `../nur-packages/default.nix` already exposes `roots = pkgs.callPackage ./pkgs/roots { };`, so `dotnix` only needed to surface that existing overlay package.
- Added `roots` to `flake.nix` under `packages = inherit (allPkgs) ...;` so it is available as `.#packages.<system>.roots`.
- Added `roots` to the shared Home Manager package list in `nix/modules/home/packages.nix` so it is installed on both Linux and macOS like the other shared CLI tools.
- Verified `nix eval --impure --override-input nur-packages path:../nur-packages .#packages.aarch64-darwin.roots.pname` returns `"roots"`.
- Verified the shared home package module includes `roots` with an isolated eval that reconstructs the required overlays and checks `builtins.any (...) module.home.packages`, which returned `true`.
- A full darwin configuration eval still fails in unrelated pre-existing config at `nix/modules/darwin/packages.nix` because `linear-linear` is undefined; that blocker is independent of this `roots` change.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package exposure change.

# Fix Darwin Activation Script

- [ ] Reproduce the current darwin build/activation failure and capture the exact error
- [ ] Inspect the darwin activation/homebrew modules and isolate the broken script path
- [ ] Apply the minimal fix and verify darwin evaluation/build behavior
- [ ] Record review results and doc impact

# Fix Raycast Darwin Rebuild Failure

- [ ] Reproduce the current `raycast` derivation failure with the exact builder error
- [ ] Confirm whether `raycast` should move from `pkgs.brewCasks` to `homebrew.casks`
- [ ] Apply the minimal darwin package-list fix
- [ ] Verify the darwin rebuild path reaches past `raycast` and record review/doc impact

# Fix Missing `roots` Package On Darwin Rebuild

- [x] Reproduce the current `darwin-rebuild` failure and capture the exact `undefined variable 'roots'` error
- [x] Inspect the shared Home Manager package list and flake exports to confirm how `roots` is wired
- [x] Update the pinned `nur-packages` input so the package set actually exports `roots`
- [x] Verify darwin evaluation reaches past the previous failure and record review/doc impact

## Review

- Updated `flake.lock` to move `nur-packages` from `7c42494bb8cb32f37dea3bb947881c3ca33c721a` (2026-04-19) to `b471f4feaa4c4c926e2bf39bb4e0ab083bb7d2a0` (2026-05-05).
- Kept the existing `roots` additions in `flake.nix` and `nix/modules/home/packages.nix`; after the input update they now resolve correctly without extra guards or fallback logic.
- Verified `nix eval --impure .#packages.aarch64-darwin.roots.pname` returns `"roots"`.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.home.packages --apply 'pkgs: builtins.any (pkg: (pkg.pname or null) == "roots") pkgs'` returns `true`.
- Verified the full darwin toplevel derivation evaluates with `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.system.build.toplevel.drvPath`, which returned `"/nix/store/1v15a90d89q02i10dfpsr01i2x3qbp7j-darwin-system-26.05.06648f4.drv"`.
- Remaining output during verification was limited to the separate warning: `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this lockfile/input refresh.

# Add Google Drive On macOS

- [x] Record the requested macOS app change and inspect the current darwin package strategy
- [x] Confirm `pkgs.brewCasks.google-drive` resolves in the darwin flake context
- [x] Add `google-drive` to the darwin app package list in the appropriate module
- [x] Verify the evaluated darwin package set includes `google-drive` and record review/doc impact

## Review

- `google-drive` resolves through `pkgs.brewCasks`, but applying the config failed because `GoogleDrive.dmg` hit a fixed-output hash mismatch (`specified sha256-AAAA...`, `got sha256-cEYTNYjgoLrL75U9MXBH2xK98Nz/IjHgPxa9WzRmDZE=`).
- To keep the app installable without patching upstream `brew-nix` metadata in this repo, the configuration was switched from `nix/modules/darwin/packages.nix` to `nix/modules/darwin/homebrew.nix`.
- Added `google-drive` to the darwin Homebrew `casks` list in `nix/modules/darwin/homebrew.nix`.
- Verified `darwinConfigurations.M2-MacBook-Air.config.homebrew.casks` contains an entry with `name == "google-drive"` via `nix eval --impure --expr`, which returned `true`.
- Applying the change with `sudo nix run .#switch` progressed past the previous hash-mismatch failure and generated the Brewfile, but final installation still requires an interactive sudo password entry on the machine.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package-list change.

# Fix VMware Fusion Darwin Rebuild Failure

- [x] Inspect the current macOS app wiring and confirm why `darwin-rebuild` is trying to build `vmware-fusion` as a Nix derivation
- [x] Move `vmware-fusion` from darwin `home.packages` to `homebrew.casks`
- [x] Remove `vmware-fusion` from managed darwin apps after confirming the Homebrew cask is disabled upstream
- [ ] Verify the darwin configuration evaluates without any managed `vmware-fusion` dependency and record doc impact

## Review

- The first failure came from `nix/modules/darwin/packages.nix` pulling `pkgs.brewCasks.vmware-fusion`, which forces a Nix build that downloads Broadcom-hosted artifacts during evaluation/build.
- Moving it to `homebrew.casks` was still insufficient: Homebrew now marks `vmware-fusion` as disabled because it requires authenticated download upstream, and `brew bundle` still fails against the Broadcom URL.
- To make `darwin-rebuild` reliable again, `vmware-fusion` has been removed from managed darwin apps entirely. If needed, it must be installed and updated manually outside this Nix/Homebrew workflow.

# Fix VS Code Darwin Rebuild Failure

- [x] Reproduce the current `visual-studio-code` derivation failure and confirm it comes from `pkgs.brewCasks`
- [x] Move VS Code from darwin `home.packages` to `homebrew.casks` with the smallest possible change
- [x] Verify darwin evaluation/build planning no longer includes the broken Nix-built VS Code derivation
- [x] Record review results and doc impact

## Review

- The failure came from `nix/modules/darwin/packages.nix` pulling `pkgs.brewCasks.visual-studio-code`, which makes `darwin-rebuild` build the VS Code cask as a Nix derivation and unpack the upstream ZIP with 7-Zip.
- The upstream archive now contains symlink layout that 7-Zip rejects as `Dangerous link via another link`, so the reliable fix in this repo is to stop managing VS Code through `brew-nix`.
- Removed `visual-studio-code` from `nix/modules/darwin/packages.nix` and added `"visual-studio-code"` to `nix/modules/darwin/homebrew.nix`, keeping the app managed on macOS but through Homebrew activation instead of a Nix build.
- Verified `home.packages` no longer contains VS Code: `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.home.packages --apply 'pkgs: builtins.any (pkg: (pkg.pname or pkg.name or null) == "visual-studio-code") pkgs'` returned `false`.
- Verified `homebrew.casks` now contains VS Code: `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.homebrew.casks --apply 'casks: builtins.any (c: (c.name or null) == "visual-studio-code") casks'` returned `true`.
- Verified the darwin dry-run build plan no longer includes `visual-studio-code-1.118.1.drv`; it now evaluates successfully through `Brewfile.drv` and `darwin-system-26.05.06648f4.drv`.
- Remaining evaluation noise is limited to the existing warning: `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package-routing fix.

# Add VMware Fusion On macOS

- [x] Record the requested macOS app change and inspect the current darwin package strategy
- [x] Add `vmware-fusion` to the darwin app package list in the appropriate module
- [x] Verify the evaluated darwin package set includes `vmware-fusion` and record review/doc impact

## Review

- Added a dedicated `pi5` NixOS host entry to the flake and kept the configuration headless and SSH-focused.
- Split the Pi5 host off from the heavier Linux desktop/server profiles so the new machine does not inherit unrelated GUI or desktop packages.
- Updated repository docs and architecture notes to mention the new Pi5 target.
- Verification is still in progress; final eval/build results will be recorded after the host config is wired up.

## Review

- `vmware-fusion` is available through `pkgs.brewCasks`, so the change was added to `nix/modules/darwin/packages.nix` instead of `nix/modules/darwin/homebrew.nix` to match the repo's current macOS app strategy.
- Added `vmware-fusion` under the darwin `# Development` brew-nix cask list in `nix/modules/darwin/packages.nix`.
- Verified `darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.home.packages` includes a package with `name == "vmware-fusion-13.6.3-24585314"` via `nix eval --impure`, which returned `true`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package-list change.

# Migrate Editor Settings Into Nix

- [x] Inventory the current VS Code user settings and separate portable config from runtime state
- [x] Import the managed VS Code config files into this repo as Nix data
- [x] Add a Home Manager module that manages `Code/User` settings and mirrors the same config into `Cursor/User`
- [x] Wire the module into the shared home imports and verify evaluation
- [x] Record the current editor extension inventory and back up the original local files
- [x] Mirror the current Cursor extension set into Nix-managed editor extension directories
- [x] Record review results and doc impact

## Review

- Added `nix/modules/home/programs/vscode.nix` and imported it from `nix/modules/home/default.nix`.
- Adopted the current Cursor `settings.json` as the source of truth, then carried forward the VS Code-only `github.copilot.nextEditSuggestions.enabled = true` and `prisma.showPrismaDataPlatformNotification = false`.
- Dropped the VS Code-only background image settings because both referenced local files are missing.
- Normalized `keybindings.json` into Nix data and removed repeated duplicate `cmd+i` bindings while preserving behavior.
- Config is generated as JSON through Home Manager `home.file` for both `~/Library/Application Support/Code/User/{settings,keybindings}.json` and `~/Library/Application Support/Cursor/User/{settings,keybindings}.json`.
- Added `nix/modules/home/programs/cursor-extensions.json` as a snapshot of the current Cursor extension set.
- Added `z-ai/editor-inventory.md` with the common / VS Code-only / Cursor-only extension inventory.
- Backed up the original local editor files under `backups/editor/2026-04-17/`.
- The current Cursor extension directories are mirrored into both `~/.cursor/extensions` and `~/.vscode/extensions` through Nix-managed symlinks.
- Verified evaluation with `nix eval --impure`:
  - `Code/User/settings.json` and `Code/User/keybindings.json` are present in `home.file`
  - `Cursor/User/settings.json` and `Cursor/User/keybindings.json` are present in `home.file`
  - `.vscode/extensions` and `.cursor/extensions` are present in `home.file`
  - `github.copilot.nextEditSuggestions.enabled = true`
  - `prisma.showPrismaDataPlatformNotification = false`
  - `terminal.external.osxExec = "Ghostty.app"`
- Formatting tool impact: `alejandra` is not installed in this environment, so no formatter pass was run.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this settings migration.

# Add apm To LLM Agents

- [x] Record the requested package change and inspect the current llm agent package list
- [x] Add `apm` to the shared `pkgs.llm-agents` package list
- [x] Verify the edit and record review/doc impact

## Review

- Added `apm` to the shared `pkgs.llm-agents` package list in `nix/modules/home/programs/ai-tools.nix`.
- Verified `pkgs.llm-agents.apm` resolves with `nix eval --impure --expr`, which returned `"apm"`.
- Verified the Darwin Home Manager package set includes `pkgs.llm-agents.apm` with `nix eval --impure --expr`, which returned `true`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this package-list change.

# Add good-first-issue-creator Skill

- [x] Inspect local skill conventions and define the new skill scope/name
- [x] Initialize `agents/skills/good-first-issue-creator`
- [x] Write the skill instructions and any minimal supporting resources
- [x] Validate the skill and record doc impact

## Review

- Added a new local skill at `agents/skills/good-first-issue-creator/` with repo-local placement matching the existing `agents/skills/*` convention.
- Initialized the skill via the upstream `skill-creator` `init_skill.py` helper, which created both `SKILL.md` and `agents/openai.yaml`.
- Replaced the template `SKILL.md` with a concise workflow for drafting newcomer-friendly GitHub issues: candidate selection, scope pressure-testing, issue structure, scoping heuristics, and output expectations.
- Kept the skill intentionally minimal: no `scripts/`, `references/`, or `assets/` were added because the workflow does not need deterministic helpers yet.
- The provided `quick_validate.py` could not run in this environment because `python3` is missing the `yaml` module (`ModuleNotFoundError: No module named 'yaml'`), so the same validation rules were re-run with Ruby's built-in YAML support and returned `Skill is valid!`.
- Doc impact: none. No updates are needed in `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/`, or `agents/README.md` because those files already document the skill mechanism and local skill source-of-truth path.

# Redesign ADR Skill In English

- [x] Inspect the current `agents/skills/adr` files and compare them with the repo's current skill design patterns
- [x] Rewrite `agents/skills/adr/SKILL.md` in English with a cleaner structure and a narrower, more maintainable core workflow
- [x] Add or reorganize supporting reference material if the detailed guidance should move out of `SKILL.md`
- [x] Update `agents/skills/adr/evals/evals.json` so the eval prompts and expectations match the redesigned skill
- [x] Verify the changed files for consistency and record doc impact

## Review

- Rewrote `agents/skills/adr/SKILL.md` in English and narrowed it to the routing layer: when to use the skill, how to frame the decision, when to use the default versus expanded ADR shape, and how to make the output enforceable.
- Split detailed guidance out of `SKILL.md` into `agents/skills/adr/references/template.md` and `agents/skills/adr/references/examples.md`, following the repo pattern of keeping the skill body lean and moving heavier guidance into references.
- Added `agents/skills/adr/references/location.md` so the skill now covers repo placement, naming, and monorepo-specific ADR directory rules instead of stopping at document content alone.
- Added `agents/skills/adr/references/readme-template.md` as an optional scaffold for `docs/adr/README.md`, so the skill can recommend a small index file without forcing extra repo scaffolding.
- Replaced the old fixed four-section format with a more standard ADR structure centered on `Status`, `Context`, `Decision`, `Consequences`, and `Adoption and Exceptions`, with an expanded template for higher-risk or more contested decisions.
- Preserved multilingual usefulness by explicitly instructing the skill to keep the user's language unless they request another one, instead of forcing English output just because the skill source is now in English.
- Updated `agents/skills/adr/evals/evals.json` to English prompts and expectations that match the redesigned structure and emphasize rationale, tradeoffs, and enforcement.
- Verified file layout with `find agents/skills/adr -maxdepth 3 -type f | sort`.
- Verified JSON validity with `jq empty agents/skills/adr/evals/evals.json`.
- Doc impact: none outside the skill itself. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this change.

# Add Maxon To Homebrew

- [x] Record the requested Homebrew change and inspect the darwin cask list
- [x] Add `maxon` to the darwin Homebrew cask list
- [x] Verify the edit and record review/doc impact

## Review

# Tighten ADR Skill Scope

- [x] Add explicit ADR vs Design Doc guidance to the ADR skill
- [x] Remove `agents/skills/adr/references/examples.md`
- [x] Remove `agents/skills/adr/evals/evals.json`
- [x] Verify the remaining ADR skill references and record doc impact

## Review

- Added an `ADR vs Design Doc` section to `agents/skills/adr/SKILL.md` so the skill now explains the decision-history role of ADRs versus the implementation-planning role of design docs.
- Removed `agents/skills/adr/references/examples.md` because the examples were not essential once the skill focused on routing and templates.
- Removed `agents/skills/adr/evals/evals.json` because this local skill does not need a bundled eval fixture for day-to-day repo use.
- Simplified the reference routing so the ADR skill now points only to the template, repo placement guidance, and optional ADR README scaffold.
- Verified the remaining ADR skill file set is coherent after the removals.
- Doc impact: none outside the skill and `z-ai` task logs. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this cleanup.

# Add External ADR References

- [x] Add the provided AWS and ADR project links to the ADR skill reference surface
- [x] Keep the links in a reference file instead of bloating the core skill body
- [x] Verify the remaining ADR skill files are still coherent

## Review

- Added the AWS Prescriptive Guidance ADR FAQ link and the adr.github.io template link under `agents/skills/adr/references/template.md` as explicit external references.
- Updated `agents/skills/adr/SKILL.md` so the routing layer now points users to those external sources when they want public ADR guidance or template references.
- Verified the ADR skill file set remains coherent after the cleanup and link additions.
- Doc impact: none outside the skill and `z-ai` logs.

- Added `maxon` to the darwin Homebrew `casks` list in `nix/modules/darwin/homebrew.nix`.
- Verified the evaluated `darwinConfigurations.M2-MacBook-Air.config.homebrew.casks` contains an entry with `name == "maxon"` via `nix eval --impure --expr`, which returned `true`.
- Note: `homebrew.casks` evaluates to attribute sets, not raw strings, so the initial string-membership check was corrected to check `c.name`.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this Homebrew cask change.

# Silence Neovim Language Host Warnings

- [x] Record the requested Neovim warning cleanup and inspect the Home Manager module
- [x] Set `programs.neovim.withRuby = false;` and `programs.neovim.withPython3 = false;`
- [x] Verify the evaluated Home Manager config reflects both flags as `false` and record review/doc impact

## Review

- Added `programs.neovim.withRuby = false;` and `programs.neovim.withPython3 = false;` to `nix/modules/home/programs/neovim.nix` to opt into the new Home Manager defaults explicitly.
- Verified `darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.programs.neovim.withRuby` evaluates to `false` with `nix eval --impure`.
- Verified `darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.programs.neovim.withPython3` evaluates to `false` with `nix eval --impure`.
- The temporary `--raw` verification attempt failed because Nix cannot coerce booleans to strings; rerunning without `--raw` confirmed the values directly.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this warning cleanup.

# Remove Deprecated System Argument Usage

- [x] Inspect the warning and compare host definitions that pass `system`
- [x] Remove deprecated top-level `system` arguments from the affected host definitions
- [x] Verify the host definitions now match the warning-free pattern and record review/doc impact

## Review

- The deprecated warning source was the top-level `system` argument passed into `nix-darwin.lib.darwinSystem` and `nixpkgs.lib.nixosSystem` in `nix/hosts/M2-MacBook-Air/default.nix` and `nix/hosts/X870-Stell-Legend-WiFi/default.nix`.
- `nix/hosts/UM790-Pro/default.nix` already used the warning-free pattern, so the fix was to align the other two hosts with it and keep platform selection flowing through `nixpkgs.pkgs = mkPkgs system;`.
- Removed `inherit system;` from the affected host definitions and left the rest of the module graph unchanged.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.system.stateVersion` returns `6` without the deprecated `system` warning.
- Verified `nix eval --impure .#nixosConfigurations.X870-Stell-Legend-WiFi.config.system.stateVersion` returns `"25.11"` without the deprecated `system` warning.
- Remaining evaluation noise observed during verification was limited to the dirty Git tree notice and the missing root channel search-path warning on Linux.
- Doc impact: none. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this cleanup.

# Add Difit Skills Source

- [x] Record the requested `difit-skills` integration and inspect the current agent-skills config
- [x] Add the `difit-skills` flake input and register it as an agent-skills source
- [x] Enable the `difit` source in agent-skills
- [x] Verify the evaluated config includes the `difit` agent-skills source/enablement and record review/doc impact

## Review

- Added `difit-skills` as a non-flake input in `flake.nix` pointing at `github:yoshiko-pg/difit`.
- Updated `flake.lock` to pin `difit-skills` to commit `71b411d7656301f5ecd8b2785c70b2f5e5b5a604` (2026-04-17).
- Registered a new `programs.agent-skills.sources.difit` source in `nix/modules/home/agent-skills.nix` with `subdir = "skills";`.
- Added `"difit"` to `programs.agent-skills.skills.enableAll` so the source is deployed alongside the other auto-enabled skill collections.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.programs.agent-skills.sources.difit.subdir` returns `"skills"`.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.home-manager.users.yuta.programs.agent-skills.skills.enableAll` includes `"difit"`.
- Verification required redirecting `XDG_CACHE_HOME` to `/tmp` and running Nix with elevated permissions because sandboxed access to the Nix daemon and default cache path was blocked.
- Doc impact: none. Per-skill entries were intentionally not added to `README.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/` to avoid drift.

# Migrate Custom Packages To nur-packages

- [x] Inventory which `nix/overlays` entries are standalone packages versus dotnix-local overrides
- [x] Move standalone package definitions into `../nur-packages/pkgs` and expose them from `../nur-packages/default.nix` / `flake.nix`
- [x] Update `dotnix` to consume migrated packages from `nur-packages` and keep only local overlays that still belong here
- [x] Verify package resolution/evaluation in both repos and record doc impact

## Review

- Moved these standalone package definitions from `dotnix/nix/overlays` into `../nur-packages/pkgs`: `bit-vcs`, `continues`, `difit`, `git-now`, `jj-desc`, `keifu`, `opensrc`, `polycat`, `pretty-ts-errors-markdown`, `readout`, `similarity-ts`, `tunnelto`.
- Updated `../nur-packages/default.nix` to expose the migrated package set and `../nur-packages/flake.nix` to export `overlays`.
- Updated `../nur-packages/overlays/default.nix` so `inputs.nur-packages.overlays.default` can be consumed from `dotnix`.
- Reduced `dotnix/nix/overlays/default.nix` to dotnix-local overlays only: `dev-tools.nix`, `speechrecognition.nix`, `tree-sitter-moonbit.nix`.
- Updated `dotnix/flake.nix` to import `nur-packages` from the sibling path input `path:../nur-packages`, apply `inputs.nur-packages.overlays.default`, and keep exporting moved packages from `packages`.
- Removed the migrated standalone overlay files from `dotnix/nix/overlays/`.
- Updated `AGENTS.md` and `CLAUDE.md` to reflect that standalone package definitions now live in the sibling `nur-packages` repository. `README.md` was intentionally left unchanged after user direction.
- Verified `nur-packages` package resolution with `nix eval --impure --expr 'let pkgs = import <nixpkgs> { system = "aarch64-darwin"; }; in (import ./default.nix { inherit pkgs; }).difit.pname'`, which returned `"difit"`.
- Verified `dotnix` package wiring with `nix eval --impure --override-input nur-packages path:../nur-packages .#packages.aarch64-darwin.readout.pname`, which returned `"readout"`.
- Updated `../nur-packages/flake.lock` to `nixos-unstable` and refreshed `dotnix/flake.lock` for the current sibling `nur-packages` state.

# Create Contest Repository

- [x] Confirm repository inputs and note assumptions
- [x] Add the `contest` GitHub repository to `homelab/tofu/github/repositories.tf`
- [x] Apply OpenTofu and verify the repository exists remotely
- [x] Clone the new repository locally and sync generated default files
- [x] Push the initial repository state that matches the requested empty setup
- [x] Commit and push the `homelab` OpenTofu change
- [x] Record review results and doc impact

## Review

- Assumptions used: `contest`, `public`, no description, no `license_template`, no `gitignore_template`, and no toolchain-specific flake bootstrap.
- Added `resource "github_repository" "contest"` to `../homelab/tofu/github/repositories.tf` with the standard repository settings used elsewhere in the workspace.
- `nix develop --command tofu apply -auto-approve` succeeded in `../homelab/tofu/github` after supplying a fresh HCP Terraform token because the stored `app.terraform.io` credential returned `unauthorized`.
- Verified the repository exists at `https://github.com/yutakobayashidev/contest`, is public, and now has `main` as the default branch.
- Cloned the repository into `../contest`, added a minimal `README.md`, and pushed the initial commit `feat: init contest repository`.
- Committed and pushed the homelab change as `feat: add contest repository to OpenTofu`.
- Doc impact: none for `README.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/`. The change only adds repository management state plus the new repository itself.

# Restrict Markitdown To Linux

- [ ] Record the package-scope change in the shared Home Manager package list
- [ ] Move `python313Packages.markitdown` from the shared package set to the Linux-only package set
- [ ] Verify Darwin excludes `markitdown` while Linux still includes it, then record review/doc impact

# Review And Commit Current Diff

- [x] Review the current staged and unstaged diff for correctness and commit scope
- [x] Stage the intended final changes and create a commit
- [x] Record review results and doc impact

## Review

- Reviewed the staged Nix/macOS changes plus the unstaged `codex/config.toml` addition and found no conflicting or partial edits that should be split out before commit.
- Verified `nix eval --impure .#packages.aarch64-darwin.roots.pname` returns `"roots"`.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.homebrew.casks --apply 'casks: builtins.any (c: c.name == "visual-studio-code" || c.name == "google-drive" || c.name == "raycast") casks'` returns `true`.
- Verified `nix eval --impure .#darwinConfigurations.M2-MacBook-Air.config.system.stateVersion` returns `6`.
- Observed existing evaluation noise only: dirty tree notice and the known warning that `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`.
- Doc impact: `AGENTS.md` changed and is included. `README.md`, `CLAUDE.md`, and `docs/` do not need updates for this diff set.

# Add Next.js Onboarding Skill

- [x] Define the new local skill scope and output shape for first-pass Next.js onboarding
- [x] Add `agents/skills/nextjs-onboarding/SKILL.md`
- [x] Remove fixed skill inventories from docs that would drift and point to source-of-truth paths instead
- [x] Verify the new skill file and doc updates, then record review/doc impact

## Review

- Added `agents/skills/nextjs-onboarding/SKILL.md` as a read-first onboarding skill for existing Next.js repos, focused on repo hygiene checks the user explicitly cares about: exact dependency pinning, pnpm strict catalog settings, `.node-version`, `knip`, env validation, `.env.sample`, and typed env access.
- Tightened the skill description so it triggers on first-pass setup review requests rather than broad codebase orientation alone.
- Removed fixed skill inventories from `README.md`, `CLAUDE.md`, and `agents/README.md`, and replaced them with source-of-truth references to `agents/skills/` and `nix/modules/home/agent-skills.nix`.
- Verified the new skill file contents with `sed -n` and confirmed the old fixed-list headings no longer exist with `rg -n "Key skills:|主なスキル：|利用可能なスキル" README.md CLAUDE.md agents/README.md`.
- Doc impact: `README.md`, `CLAUDE.md`, and `agents/README.md` intentionally changed to reduce maintenance drift. `AGENTS.md` and `docs/` did not need updates for this skill addition.

# Add Dependency Preference Reference To Next.js Onboarding Skill

- [x] Add a lightweight dependency-choice entrypoint to `SKILL.md`
- [x] Add `agents/skills/nextjs-onboarding/references/dependencies.md`
- [ ] Verify the package guidance wording stays preference-based rather than claiming formal deprecation

# Add Testing Strategy Reference To Next.js Onboarding Skill

- [x] Keep `SKILL.md` lean and add only a testing-strategy entrypoint
- [x] Add `agents/skills/nextjs-onboarding/references/testing.md` for real-DB parallel test guidance
- [x] Record review results and doc impact

## Review

- Added a new `testing strategy` checklist item to `agents/skills/nextjs-onboarding/SKILL.md` and explicitly directed deeper testing reviews to `references/testing.md`.
- Added `agents/skills/nextjs-onboarding/references/testing.md` covering:
  - real Postgres integration tests with Testcontainers and dynamic ports
  - shared Prisma DB setup/truncate helpers
  - Vitest setup via `vi.hoisted`
  - parallel Playwright workers with isolated DB and app processes
  - test-mode auth, storageState reuse, and worker fixtures
- Kept `SKILL.md` focused on routing and left the implementation-heavy testing guidance in the reference file to avoid further bloating the always-loaded instructions.
- Doc impact: no changes needed to `README.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/`. This is an internal skill-content expansion only.

# Replace wt Command With W

- [x] Inspect current `wt` / worktree shell wiring and affected docs
- [x] Keep `git wt` available and add the requested `W()` picker alongside it
- [x] Verify zsh syntax and record doc impact

## Review

- Restored `eval "$(git wt --init zsh)"` in `zsh/zshrc`, so the existing `git wt` integration remains available in interactive zsh sessions.
- Replaced the old `gwt` worktree picker with the requested `W()` implementation in [zsh/functions/W.zsh](/Users/yuta/ghq/github.com/yutakobayashidev/dotnix/zsh/functions/W.zsh:1), alongside `git wt`.
- Updated [zsh/functions/README.md](/Users/yuta/ghq/github.com/yutakobayashidev/dotnix/zsh/functions/README.md:1) to document `W` instead of `gwt`.
- Removed the stale `unalias gwt` cleanup from [zsh/config/oh-my-zsh.zsh](/Users/yuta/ghq/github.com/yutakobayashidev/dotnix/zsh/config/oh-my-zsh.zsh:1).
- Verified `zsh -n zsh/zshrc zsh/functions/W.zsh` succeeds.
- Verified an interactive zsh loads both `W` and `wt`.
- Interactive verification emitted existing sandbox write warnings for `.zcompdump`, oh-my-zsh completion cache, and `zsh-abbr`, but the shell wiring being checked still loaded correctly.

# Add Hiroppy Testing References To Next.js Onboarding Skill

- [x] Inspect the current testing reference structure and choose the minimal insertion point
- [x] Add the requested `hiroppy.me` articles to `agents/skills/nextjs-onboarding/references/testing.md`
- [x] Verify the links render cleanly in-context and record doc impact

## Review

- Added an `Additional references` section to `agents/skills/nextjs-onboarding/references/testing.md`.
- Included the requested hiroppy articles for Testcontainers-based parallel tests and isolated e2e setup.
- Verified the final placement and formatting with `tail` and `git diff`.
- Doc impact: none beyond the skill reference itself. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this internal skill-reference tweak.

# Add nuqs To Next.js Dependency Preferences

- [x] Inspect the current dependency preference structure and choose the right insertion point for `nuqs`
- [x] Add `nuqs` to `agents/skills/nextjs-onboarding/references/dependencies.md` with preference-based wording
- [x] Verify formatting and note doc impact

## Review

- Added `nuqs` to the preferred replacements table as the default for non-trivial URL-backed UI state in Next.js.
- Added a dedicated `manual URL search param state sync -> nuqs` guidance section so the recommendation stays preference-based instead of reading like a blanket rule.
- Added `nuqs` to source notes and primary sources, pointing to the official docs at `https://nuqs.dev/`.
- Verified the final formatting and placement with `sed` and `git diff`.
- Doc impact: none beyond the skill reference itself. `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` do not need updates for this internal skill-reference tweak.

# Add Raspberry Pi 5 NixOS Host

- [x] Confirm the intended Pi 5 migration shape and target hostname
- [ ] Add the `pi5` NixOS host, including flake wiring and Pi-specific modules
- [ ] Add a minimal server-oriented profile for the new host
- [ ] Update repo docs and verify the new configuration evaluates

# Add Luanti

- [ ] Inspect the current shared package layout and confirm whether `luanti` should be common or OS-specific
- [ ] Add `luanti` to the minimal package list location
- [ ] Verify evaluation on both Darwin and Linux package sets and record doc impact

# Add Actrun Flake Output

- [ ] Inspect the current `actrun` integration in `flake.nix` and choose the minimal source-of-truth path
- [ ] Update flake inputs/overlays so `actrun` comes from the requested flake input
- [ ] Expose `actrun` in top-level flake packages and the default dev shell
- [ ] Verify flake evaluation and record doc impact

# Switch Codex Config To Writable Copy

- [x] Replace the `mkOutOfStoreSymlink` for `codex/config.toml` with a generated copy in `home.activation`
- [x] Restore the Codex TOML contents from the existing `codex/config.toml`
- [x] Verify the module evaluates cleanly and record doc impact
