# Deploy Copywriter Agent

This runbook connects the medical copywriter skill to the existing Hermes installation.

## Target Paths

- Skill: `/home/hermes/.hermes/skills/copywriter-agent/SKILL.md`
- Workspace context: `/srv/hermes/workspace/docs/copywriting/`
- Service restart: `hermes-gateway.service`

## Safety

- Do not copy secrets.
- Do not print `.env` or `auth.json`.
- Do not change SSH hardening in this runbook.
- Restart only `hermes-gateway.service`.

## Deploy

Windows:

```powershell
.\scripts\deploy-copywriter-agent.ps1
```

Linux/macOS/Git Bash:

```sh
./scripts/deploy-copywriter-agent.sh
```

## Verify

After deploy, send a Telegram message to Hermes:

```text
Сделай Telegram-пост для врача-кардиолога: почему после 40 лет важно проверить сосуды. Стиль экспертный, спокойно, без запугивания.
```

Expected behavior:

- Hermes recognizes the task as medical copywriting.
- The answer has a headline, hook, short paragraphs, practical value, and soft CTA.
- The answer avoids miracle claims, aggressive sales, and invented facts.

