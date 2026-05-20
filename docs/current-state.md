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
