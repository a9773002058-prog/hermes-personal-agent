# Update Telegram Token Runbook

This runbook is intentionally documentation-only. Do not rotate or replace the Telegram token without explicit confirmation.

## Safety

- Never paste the token into chat.
- Never commit the token.
- Store the token only on the VDS in the approved runtime secret location.
- After changing the token, restart only the required service.

## Suggested Process

1. Confirm the token rotation with the user.
2. Open an SSH session to the VDS.
3. Edit the runtime secret file directly on the server.
4. Restart `hermes-gateway.service`.
5. Run `scripts/healthcheck.ps1` or `scripts/healthcheck.sh`.
6. Send a Telegram test message.
7. Document the date and result in `docs/current-state.md`, without the token value.

## Do Not Do

- Do not commit `.env`.
- Do not copy `auth.json`.
- Do not paste service logs if they may include tokens.
