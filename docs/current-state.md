# Current State

Date: 2026-05-20

Hermes is expected to be installed on the VDS `178.104.60.170` with Telegram gateway already configured.

## Known Local State

- Local OS: Windows PowerShell
- Local SSH client: available
- Local Git: available
- GitHub CLI: not installed at initial discovery
- Dedicated VDS SSH key: `C:\Users\User\.ssh\hermes-vds\hermes_vds_ed25519`
- Local repo path: `C:\Users\User\Projects\hermes-personal-agent`

## SSH Status

Initial checks reached the server, but `root@178.104.60.170` and `hermes@178.104.60.170` returned `Permission denied (publickey)`.

Expected public key to install:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4uc4MsVaYCHQFQ+o/iO7i10nVvz9AS4QFMGBJ6gpxy hermes-vds-178.104.60.170
```

The server currently presents ED25519 host fingerprint:

```text
SHA256:yteP5DYgFogqJO3/LKcR+nPtb98+psrjCom1ghSwDxw
```

## Pending Verification

- Confirm SSH key login works for `root`.
- Run read-only healthcheck.
- Sync safe snapshots.
- Verify no secrets.
- Create private GitHub repository and push.

## Copywriter Agent

Status: prepared locally, not yet deployed to VDS because SSH key login still returns `Permission denied (publickey)`.

Deploy attempt on 2026-05-21 failed before copying files because SSH authentication was rejected for `root@178.104.60.170`.

Follow-up on 2026-05-21: SSH key login started working after the VDS restart, but the server booted into rescue mode.

Observed state:

- hostname: `rescue`
- OS: Debian GNU/Linux 12 rescue environment
- root filesystem: `overlay`
- main disk visible as `sda`
- no `hermes` Linux user in the running rescue environment
- no `/srv/hermes` in the running rescue environment
- no `hermes-gateway.service` unit in the running rescue environment

Conclusion: copywriter deployment cannot be applied while the VDS is in rescue mode. Boot the VDS back into the normal installed system first, then rerun `scripts/deploy-copywriter-agent.ps1`.

Follow-up after disabling rescue mode: SSH key authentication is rejected again for both `root` and `hermes`. This likely means the public key was available only in the rescue environment or provider rescue access, not in the normal installed system's `authorized_keys`.

Next required action: add the local public key to the normal installed system, preferably `/root/.ssh/authorized_keys` if root SSH login is allowed, or to the actual admin user used by the Hermes installation.

Follow-up in rescue mode on 2026-05-21: mounted the installed Ubuntu 22.04 system from `/dev/sda1`, verified that `hermes` user, `/home/hermes`, and `/srv/hermes` exist, and added the local public key to the installed system's `/root/.ssh/authorized_keys`. The disk was synced and unmounted cleanly.

Next required action: disable rescue mode in the provider panel and reboot into the normal installed system. Then verify SSH key login for `root@178.104.60.170` and deploy the copywriter agent.

Follow-up after normal boot on 2026-05-21: VDS booted as `med-ai` from `/dev/sda1`, SSH key login for `root` works, `hermes` user exists, `/srv/hermes` exists, and `hermes-gateway.service` is `active` and `enabled`.

Copywriter agent deployment status: deployed successfully to `/home/hermes/.hermes/skills/copywriter-agent/SKILL.md`; copywriting context deployed to `/srv/hermes/workspace/docs/copywriting/`; `hermes-gateway.service` restarted and remained `active`.

## Nightly GitHub Sync

Status: installed and verified on 2026-05-23.

Installed on VPS:

- `/usr/local/bin/hermes-nightly-sync.sh`
- `/etc/systemd/system/hermes-nightly-sync.service`
- `/etc/systemd/system/hermes-nightly-sync.timer`
- `/srv/hermes/github-sync/hermes-personal-agent`
- `/home/hermes/.ssh/github_sync_ed25519`

The GitHub deploy key is registered on the private repo with write access. Manual service test succeeded and pushed commit `c178e26` to GitHub.

Timer status during setup:

- `hermes-nightly-sync.timer`: active/waiting
- next observed run: 2026-05-24 around 03:29 UTC

Prepared files:

- `deploy/hermes/skills/copywriter-agent/SKILL.md`
- `deploy/hermes/workspace/docs/copywriting/voice-guide.md`
- `deploy/hermes/workspace/docs/copywriting/medical-claims-policy.md`
- `deploy/hermes/workspace/docs/copywriting/banned-phrases.md`
- `deploy/hermes/workspace/docs/copywriting/headline-bank.md`
- `deploy/hermes/workspace/docs/copywriting/offers.md`
- `deploy/hermes/workspace/docs/copywriting/swipe-file.md`
- `scripts/deploy-copywriter-agent.ps1`
- `scripts/deploy-copywriter-agent.sh`

Target deployment paths:

- `/home/hermes/.hermes/skills/copywriter-agent/SKILL.md`
- `/srv/hermes/workspace/docs/copywriting/`

Once SSH access works, run:

```powershell
.\scripts\deploy-copywriter-agent.ps1
```
