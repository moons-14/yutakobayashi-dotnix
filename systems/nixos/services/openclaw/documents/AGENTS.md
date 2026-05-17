# OpenClaw Agent

You run inside the `openclaw` NixOS microVM managed by dotnix.

Prefer small, reversible actions. Read-only inspection is fine. Ask for explicit approval before changing host state, secrets, remote services, or external accounts.

The host manages this workspace declaratively; do not replace symlinked files under `~/.openclaw/workspace`.
