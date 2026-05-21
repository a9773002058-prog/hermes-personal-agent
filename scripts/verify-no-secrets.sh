#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FILES=$(git ls-files --cached --others --exclude-standard)
else
  FILES=$(find . -type f \
    ! -path './.git/*' \
    ! -path './snapshots/hermes/logs/*' \
    ! -path './snapshots/hermes/sessions/*' \
    ! -path './snapshots/hermes/cache/*')
fi

PATTERNS='TELEGRAM_BOT_TOKEN[[:space:]]*[:=]|[0-9]{8,10}:[A-Za-z0-9_-]{30,}|OPENAI_API_KEY[[:space:]]*[:=]|ANTHROPIC_API_KEY[[:space:]]*[:=]|api[_-]?key[[:space:]]*[:=][[:space:]]*[^[:space:]]+|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|password[[:space:]]*[:=][[:space:]]*[^[:space:]]+|oauth[_-]?token[[:space:]]*[:=]|bearer[[:space:]]+[A-Za-z0-9._-]+'

FOUND=0
for file in $FILES; do
  [ -f "$file" ] || continue
  case "$file" in
    ./.git/*|./scripts/verify-no-secrets.sh|./scripts/verify-no-secrets.ps1) continue ;;
  esac
  base=$(basename "$file")
  case "$base" in
    .env|.env.*|auth.json|*.pem|*.key|id_rsa|id_ed25519)
      echo "Forbidden secret-like file tracked or present: $file"
      FOUND=1
      continue
      ;;
  esac
  if grep -EIn "$PATTERNS" "$file" >/tmp/hermes-secret-hit 2>/dev/null; then
    if grep -Ev '(api[_-]?key|token|secret|password|oauth[_-]?token)[[:space:]]*[:=][[:space:]]*REDACTED' /tmp/hermes-secret-hit >/tmp/hermes-secret-hit-filtered; then
      echo "Potential secret in $file"
      cat /tmp/hermes-secret-hit-filtered
      FOUND=1
    fi
  fi
done

if [ "$FOUND" -ne 0 ]; then
  echo "Secret verification failed."
  exit 1
fi

echo "No obvious secrets found."
