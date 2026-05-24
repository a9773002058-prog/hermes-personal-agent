# Hermes Personal Agent Ops Repo

This repository is not the Hermes source code. It is a private operations and project repository for the existing Hermes personal agent running on the VDS `178.104.60.170`.

It tracks safe project knowledge: architecture notes, runbooks, sanitized snapshots, current state, and future plans for developing Hermes into a personal multi-agent system.

## Server Defaults

- SSH host: `178.104.60.170`
- SSH user: `root`
- SSH port: `22`
- SSH key: `C:\Users\User\.ssh\hermes-vds\hermes_vds_ed25519`
- Hermes user: `hermes`
- Hermes home: `/home/hermes/.hermes`
- Hermes workspace: `/srv/hermes/workspace`
- Gateway service: `hermes-gateway.service`

## Sync From VDS

On Windows PowerShell:

```powershell
.\scripts\sync-from-vds.ps1
```

On Linux/macOS/Git Bash:

```sh
./scripts/sync-from-vds.sh
```

The sync copies only safe project state and excludes secrets, auth files, databases, caches, logs, sessions, locks, and private keys.

## Nightly VPS Sync

The VPS also runs a server-side safe sync to GitHub:

- systemd timer: `hermes-nightly-sync.timer`
- service: `hermes-nightly-sync.service`
- script: `/usr/local/bin/hermes-nightly-sync.sh`
- server clone: `/srv/hermes/github-sync/hermes-personal-agent`

It runs nightly around `03:17` server time with randomized delay, updates safe snapshots, verifies no obvious secrets, commits changes, and pushes to this private GitHub repo.

Manual check:

```powershell
ssh -i $HOME\.ssh\hermes-vds\hermes_vds_ed25519 -p 22 root@178.104.60.170 "systemctl list-timers hermes-nightly-sync.timer --all --no-pager"
```

## Healthcheck

On Windows PowerShell:

```powershell
.\scripts\healthcheck.ps1
```

On Linux/macOS/Git Bash:

```sh
./scripts/healthcheck.sh
```

The healthcheck checks the systemd gateway service, workspace presence, available Hermes version hints, and whether secret-bearing env files exist without printing their contents.

## Deploy Copywriter Agent

The medical copywriter skill is prepared in `deploy/hermes/skills/copywriter-agent/` with supporting context in `deploy/hermes/workspace/docs/copywriting/`.

After SSH access works:

```powershell
.\scripts\deploy-copywriter-agent.ps1
```

This copies the skill to `/home/hermes/.hermes/skills/copywriter-agent/`, copies copywriting context to `/srv/hermes/workspace/docs/copywriting/`, and restarts `hermes-gateway.service`.

## Before Commit

Always run:

```powershell
.\scripts\verify-no-secrets.ps1
```

or:

```sh
./scripts/verify-no-secrets.sh
```

Never commit Telegram tokens, OAuth tokens, API keys, SSH private keys, `.env`, `auth.json`, cookies, sessions, logs, or Hermes runtime databases.

## Adding Integrations Safely

Integration credentials must stay on the VDS or in an approved secret store. This repo may document required variables, scopes, setup steps, and verification commands, but must not store actual credentials.

Any integration that reads or changes external systems, such as Notion, Todoist, Google Workspace, CRM, billing, or email, needs separate confirmation before real credentials are added or write actions are enabled.

## Working With Codex or Claude

Start by reading `AGENTS.md`, `docs/current-state.md`, and the relevant runbooks. Document every VDS change in this repo. Run secret verification before every commit and keep GitHub visibility private.

## Next Steps

1. Fix SSH key access if healthcheck still reports `Permission denied`.
2. Deploy the copywriter agent with `scripts/deploy-copywriter-agent.ps1`.
3. Pull the latest GitHub changes before work: `git pull origin main`.
4. Run `scripts/sync-from-vds.ps1` when you need an immediate fresh snapshot.
5. Review sanitized snapshots.
6. Run `scripts/verify-no-secrets.ps1`.
7. Commit and push to the private GitHub repository.
