# Agent Instructions

This is a private ops/project repo for an already installed Hermes personal agent. It is not the Hermes source tree.

## Safety Rules

- Do not print, copy, summarize, or commit secrets.
- Never commit Telegram bot tokens, OAuth tokens, API keys, root passwords, SSH private keys, `.env`, `auth.json`, cookies, sessions, logs, `state.db`, or `kanban.db`.
- Run `scripts/verify-no-secrets.ps1` or `scripts/verify-no-secrets.sh` before commit.
- Treat all VDS changes as production operations and document them in this repo.
- Do not disable password login, change SSH hardening, rotate tokens, or connect new integrations unless the user explicitly approves that separate task.

## Server Context

- Existing VDS: `178.104.60.170`
- Default SSH user: `root`
- Default SSH port: `22`
- Hermes user: `hermes`
- Hermes home: `/home/hermes/.hermes`
- Hermes workspace: `/srv/hermes/workspace`
- Gateway service: `hermes-gateway.service`

## Workflow

1. Read `README.md` and `docs/current-state.md`.
2. Run a read-only healthcheck.
3. Sync snapshots only through the provided scripts.
4. Verify no secrets.
5. Document changes in `docs/`.
6. Commit only safe docs, scripts, and sanitized snapshots.

New integrations require a separate confirmation step, especially when credentials or write permissions are involved.
