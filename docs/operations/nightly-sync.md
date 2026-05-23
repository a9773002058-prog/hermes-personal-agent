# Nightly Sync

The VPS is the runtime location for Hermes. GitHub is the exchange point. Local `snapshots/workspace/` mirrors safe workspace content from `/srv/hermes/workspace`.

## What Runs On The VPS

- Script: `/usr/local/bin/hermes-nightly-sync.sh`
- Service: `hermes-nightly-sync.service`
- Timer: `hermes-nightly-sync.timer`
- Runtime user: `hermes`
- Local server clone: `/srv/hermes/github-sync/hermes-personal-agent`
- GitHub auth: SSH deploy key at `/home/hermes/.ssh/github_sync_ed25519`

## Schedule

The timer runs nightly around `03:17` server time with up to 45 minutes randomized delay.

## What It Syncs

- `/srv/hermes/workspace/**` to `snapshots/workspace/`
- `/home/hermes/.hermes/SOUL.md`
- `/home/hermes/.hermes/memories/MEMORY.md`
- `/home/hermes/.hermes/memories/USER.md`
- sanitized `/home/hermes/.hermes/config.yaml`
- `systemctl cat hermes-gateway.service`
- installed Hermes skills list
- read-only healthcheck snapshot

## What It Excludes

- `.env`
- `auth.json`
- lock and pid files
- runtime databases
- sessions
- logs
- caches
- private keys
- API tokens

## Manual Run

```bash
sudo systemctl start hermes-nightly-sync.service
sudo journalctl -u hermes-nightly-sync.service -n 100 --no-pager
```

## Local Pull Before Work

```powershell
git pull origin main
.\scripts\sync-from-vds.ps1
.\scripts\verify-no-secrets.ps1
```

## Verify Timer

```bash
systemctl status hermes-nightly-sync.timer --no-pager
systemctl list-timers hermes-nightly-sync.timer --all --no-pager
```

