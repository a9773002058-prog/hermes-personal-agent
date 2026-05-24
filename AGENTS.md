# Agent Instructions

This is a private ops/project repository for an already installed Hermes personal agent. It is not the Hermes source tree.

The live Hermes runtime is on the VPS. GitHub is the shared coordination point. Local files are an operational mirror and documentation layer.

## Current System

- VPS: `178.104.60.170`
- SSH user: `root`
- SSH port: `22`
- SSH key: `C:\Users\User\.ssh\hermes-vds\hermes_vds_ed25519`
- Hermes user: `hermes`
- Hermes home: `/home/hermes/.hermes`
- Hermes workspace: `/srv/hermes/workspace`
- Gateway service: `hermes-gateway.service`
- GitHub repo: `https://github.com/a9773002058-prog/hermes-personal-agent`
- Repo visibility: private

## Installed Capabilities

- Medical copywriter skill:
  - `/home/hermes/.hermes/skills/copywriter-agent/SKILL.md`
  - `/srv/hermes/workspace/docs/copywriting/`
- Nightly VPS to GitHub sync:
  - `/usr/local/bin/hermes-nightly-sync.sh`
  - `hermes-nightly-sync.service`
  - `hermes-nightly-sync.timer`
  - `/srv/hermes/github-sync/hermes-personal-agent`

## Safety Rules

- Do not print, copy, summarize, or commit secrets.
- Never commit Telegram bot tokens, OAuth tokens, API keys, root passwords, SSH private keys, `.env`, `auth.json`, cookies, sessions, logs, `state.db`, or `kanban.db`.
- Run `scripts/verify-no-secrets.ps1` or `scripts/verify-no-secrets.sh` before every commit.
- Treat all VPS changes as production operations and document them in this repo.
- Do not disable password login, change SSH hardening, rotate tokens, or connect new integrations unless the user explicitly approves that separate task.
- New integrations with credentials or write permissions require separate confirmation.

## Start Of Work

Before making changes:

```powershell
git pull origin main
.\scripts\healthcheck.ps1
```

If fresh server snapshots are needed immediately:

```powershell
.\scripts\sync-from-vds.ps1
.\scripts\verify-no-secrets.ps1
```

The VPS also pushes safe snapshots nightly, so always pull from GitHub before trusting local snapshots.

## Normal Workflow

1. Read `README.md`, `docs/current-state.md`, and the relevant runbook.
2. Pull latest GitHub changes.
3. Run a read-only healthcheck.
4. Use provided scripts for sync/deploy actions.
5. Update docs for every meaningful VPS change.
6. Run secret verification.
7. Commit and push safe docs, scripts, deploy files, and sanitized snapshots.

## Useful Commands

Healthcheck:

```powershell
.\scripts\healthcheck.ps1
```

Manual safe sync from VPS to local:

```powershell
.\scripts\sync-from-vds.ps1
```

Deploy medical copywriter skill:

```powershell
.\scripts\deploy-copywriter-agent.ps1
```

Check nightly sync timer:

```powershell
ssh -i $HOME\.ssh\hermes-vds\hermes_vds_ed25519 -p 22 root@178.104.60.170 "systemctl list-timers hermes-nightly-sync.timer --all --no-pager"
```

Run nightly sync manually on VPS:

```powershell
ssh -i $HOME\.ssh\hermes-vds\hermes_vds_ed25519 -p 22 root@178.104.60.170 "systemctl start hermes-nightly-sync.service && journalctl -u hermes-nightly-sync.service -n 100 --no-pager"
```

Verify no secrets:

```powershell
.\scripts\verify-no-secrets.ps1
```

## What To Commit

Safe:

- docs
- scripts
- deploy templates
- sanitized config snapshots
- safe workspace snapshots
- healthcheck snapshots
- systemd unit snapshots

Unsafe:

- raw `.env`
- `auth.json`
- databases
- sessions
- logs
- caches
- private keys
- API tokens
- copied credentials

## Copywriter Agent

The copywriter is a medical content skill for a cardiologist focused on preventive medicine, gerontology, and nutrition.

Expected behavior:

- expert but simple medical tone
- Telegram/Instagram posts with headline, hook, practical value, and soft CTA
- no aggressive sales
- no miracle promises
- no invented medical facts
- natural German when requested

Test prompt:

```text
Сделай Telegram-пост для врача-кардиолога на тему: почему после 40 лет важно проверить сосуды. Стиль экспертный, спокойно, без запугивания.
```

## If SSH Breaks

Check `docs/current-state.md` first. This project already went through rescue-mode recovery once. Do not reset the server or change SSH hardening casually. Prefer key-based access and document any recovery step.

