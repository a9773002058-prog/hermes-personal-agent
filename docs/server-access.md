# Server Access

## Defaults

- Host: `178.104.60.170`
- User: `root`
- Port: `22`
- Key: `C:\Users\User\.ssh\hermes-vds\hermes_vds_ed25519`

PowerShell example:

```powershell
ssh -i $HOME\.ssh\hermes-vds\hermes_vds_ed25519 -p 22 root@178.104.60.170
```

Shell example:

```sh
ssh -i "$HOME/.ssh/hermes-vds/hermes_vds_ed25519" -p 22 root@178.104.60.170
```

## Host Key Note

This IP had an older local `known_hosts` entry during setup. Verify the provider console or trusted installation logs before replacing the local known host entry.

Current observed ED25519 fingerprint:

```text
SHA256:yteP5DYgFogqJO3/LKcR+nPtb98+psrjCom1ghSwDxw
```

## Do Not Store

Do not store root passwords, private keys, provider console credentials, SSH config secrets, or copied `authorized_keys` content containing unrelated keys in this repository.
