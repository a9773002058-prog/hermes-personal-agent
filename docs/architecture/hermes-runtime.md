# Hermes Runtime

Hermes currently runs as an existing Telegram-facing personal assistant on the VDS.

## Expected Runtime Layout

- Hermes user: `hermes`
- Hermes home: `/home/hermes/.hermes`
- Workspace: `/srv/hermes/workspace`
- Gateway service: `hermes-gateway.service`

## Safe Snapshot Sources

- `/srv/hermes/workspace/**`
- `/home/hermes/.hermes/SOUL.md`
- `/home/hermes/.hermes/memories/MEMORY.md`
- `/home/hermes/.hermes/memories/USER.md`
- Sanitized `/home/hermes/.hermes/config.yaml`
- `systemctl cat hermes-gateway.service`
- Read-only healthcheck/status output without secrets

## Excluded Runtime State

- `.env`
- `auth.json`
- lock and pid files
- `state.db*`
- `kanban.db`
- sessions
- logs
- caches
- OAuth tokens
- Telegram tokens
- SSH private keys

## Operating Principle

This repo should describe and snapshot the system, not become the runtime. Runtime credentials and mutable operational state stay on the VDS.
