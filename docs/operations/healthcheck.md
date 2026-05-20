# Healthcheck Runbook

Use this runbook for read-only checks of the existing Hermes VDS.

## Windows

```powershell
.\scripts\healthcheck.ps1
```

## Linux/macOS/Git Bash

```sh
./scripts/healthcheck.sh
```

## Checks

- `systemctl is-active hermes-gateway.service`
- `systemctl is-enabled hermes-gateway.service`
- `/srv/hermes/workspace` exists
- Hermes version hints are discoverable
- secret-bearing env files are detected only by presence, never printed

## Expected Result

The gateway should be `active`. If it is not active, inspect service status on the VDS without printing environment variables or token-bearing logs.

Safe next command:

```sh
systemctl status hermes-gateway.service --no-pager
```

Avoid dumping full logs until token redaction is confirmed.
