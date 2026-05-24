#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
HOST="${HERMES_VDS_HOST:-178.104.60.170}"
USER="${HERMES_VDS_USER:-root}"
PORT="${HERMES_VDS_PORT:-22}"
KEY="${HERMES_VDS_KEY:-$HOME/.ssh/hermes-vds/hermes_vds_ed25519}"
SSH_OPTS="-i $KEY -p $PORT -o BatchMode=yes -o ConnectTimeout=10"

mkdir -p "$ROOT_DIR/snapshots/workspace" "$ROOT_DIR/snapshots/hermes/memories" "$ROOT_DIR/snapshots/systemd"

RSYNC_EXCLUDES="
--exclude=.env
--exclude=auth.json
--exclude=*.lock
--exclude=*.pid
--exclude=state.db*
--exclude=kanban.db
--exclude=sessions/**
--exclude=logs/**
--exclude=cache/**
--exclude=audio_cache/**
--exclude=image_cache/**
--exclude=.cache/**
--exclude=*.pem
--exclude=*.key
--exclude=id_rsa
--exclude=id_ed25519
"

if command -v rsync >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  rsync -az -e "ssh $SSH_OPTS" $RSYNC_EXCLUDES "$USER@$HOST:/srv/hermes/workspace/" "$ROOT_DIR/snapshots/workspace/"
else
  echo "rsync not found; falling back to tar over ssh"
  ssh $SSH_OPTS "$USER@$HOST" "cd /srv/hermes/workspace && tar --exclude='.env' --exclude='auth.json' --exclude='*.lock' --exclude='*.pid' --exclude='state.db*' --exclude='kanban.db' --exclude='sessions' --exclude='logs' --exclude='cache' --exclude='audio_cache' --exclude='image_cache' --exclude='.cache' --exclude='*.pem' --exclude='*.key' --exclude='id_rsa' --exclude='id_ed25519' -czf - ." | tar -xzf - -C "$ROOT_DIR/snapshots/workspace"
fi

scp $SSH_OPTS "$USER@$HOST:/home/hermes/.hermes/SOUL.md" "$ROOT_DIR/snapshots/hermes/SOUL.md" 2>/dev/null || true
scp $SSH_OPTS "$USER@$HOST:/home/hermes/.hermes/memories/MEMORY.md" "$ROOT_DIR/snapshots/hermes/memories/MEMORY.md" 2>/dev/null || true
scp $SSH_OPTS "$USER@$HOST:/home/hermes/.hermes/memories/USER.md" "$ROOT_DIR/snapshots/hermes/memories/USER.md" 2>/dev/null || true

ssh $SSH_OPTS "$USER@$HOST" "python3 - <<'PY'
from pathlib import Path
import re
p = Path('/home/hermes/.hermes/config.yaml')
if p.exists():
    text = p.read_text(errors='replace')
    text = re.sub(r'(?i)(token|secret|password|api[_-]?key|oauth|bearer)(\\s*[:=]\\s*).+', r'\\1\\2REDACTED', text)
    text = re.sub(r'\\b\\d{8,10}:[A-Za-z0-9_-]{30,}\\b', 'REDACTED_TELEGRAM_TOKEN', text)
    print(text)
PY" > "$ROOT_DIR/snapshots/hermes/config.sanitized.yaml"

ssh $SSH_OPTS "$USER@$HOST" "systemctl cat hermes-gateway.service 2>/dev/null || true" > "$ROOT_DIR/snapshots/systemd/hermes-gateway.service"
ssh $SSH_OPTS "$USER@$HOST" "find /home/hermes/.hermes/skills -maxdepth 2 -type f 2>/dev/null | sort || true" > "$ROOT_DIR/snapshots/hermes/skills.txt"
./scripts/healthcheck.sh > "$ROOT_DIR/snapshots/hermes/healthcheck.txt" || true

echo "Sync complete. Run scripts/verify-no-secrets.sh before commit."
