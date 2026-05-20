# Scripts

Configuration defaults are embedded in each script:

- host: `178.104.60.170`
- user: `root`
- port: `22`
- key: `C:\Users\User\.ssh\hermes-vds\hermes_vds_ed25519`

## Files

- `healthcheck.sh` / `healthcheck.ps1`: read-only service and runtime checks.
- `sync-from-vds.sh` / `sync-from-vds.ps1`: copy safe snapshots from the VDS.
- `verify-no-secrets.sh` / `verify-no-secrets.ps1`: fail if obvious secrets are found.

Run secret verification before every commit.
