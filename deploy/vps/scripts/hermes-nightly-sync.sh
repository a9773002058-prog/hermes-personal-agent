#!/usr/bin/env sh
set -eu

REPO_URL="${HERMES_SYNC_REPO_URL:-git@github.com:a9773002058-prog/hermes-personal-agent.git}"
REPO_DIR="${HERMES_SYNC_REPO_DIR:-/srv/hermes/github-sync/hermes-personal-agent}"
SSH_KEY="${HERMES_SYNC_SSH_KEY:-/home/hermes/.ssh/github_sync_ed25519}"
LOCK_FILE="${HERMES_SYNC_LOCK_FILE:-/tmp/hermes-nightly-sync.lock}"
HERMES_HOME="${HERMES_HOME:-/home/hermes/.hermes}"
HERMES_WORKSPACE="${HERMES_WORKSPACE:-/srv/hermes/workspace}"
SERVICE="${HERMES_GATEWAY_SERVICE:-hermes-gateway.service}"

export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

run_sync() {
  umask 077
  mkdir -p "$(dirname "$REPO_DIR")"

  if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  cd "$REPO_DIR"
  git config user.name "Hermes VPS Sync"
  git config user.email "hermes-vps-sync@users.noreply.github.com"

  git fetch origin main
  git checkout main
  git pull --rebase origin main

  mkdir -p snapshots/workspace snapshots/hermes/memories snapshots/systemd

  rsync -a --delete \
    --exclude='.env' \
    --exclude='auth.json' \
    --exclude='*.lock' \
    --exclude='*.pid' \
    --exclude='state.db*' \
    --exclude='kanban.db' \
    --exclude='sessions/**' \
    --exclude='logs/**' \
    --exclude='cache/**' \
    --exclude='audio_cache/**' \
    --exclude='image_cache/**' \
    --exclude='.cache/**' \
    --exclude='*.pem' \
    --exclude='*.key' \
    --exclude='id_rsa' \
    --exclude='id_ed25519' \
    "$HERMES_WORKSPACE/" snapshots/workspace/

  [ -f "$HERMES_HOME/SOUL.md" ] && cp "$HERMES_HOME/SOUL.md" snapshots/hermes/SOUL.md || true
  [ -f "$HERMES_HOME/memories/MEMORY.md" ] && cp "$HERMES_HOME/memories/MEMORY.md" snapshots/hermes/memories/MEMORY.md || true
  [ -f "$HERMES_HOME/memories/USER.md" ] && cp "$HERMES_HOME/memories/USER.md" snapshots/hermes/memories/USER.md || true

  python3 - <<'PY' > snapshots/hermes/config.sanitized.yaml
from pathlib import Path
import re

p = Path("/home/hermes/.hermes/config.yaml")
if p.exists():
    text = p.read_text(errors="replace")
    text = re.sub(r"(?i)(token|secret|password|api[_-]?key|oauth|bearer)(\s*[:=]\s*).+", r"\1\2REDACTED", text)
    text = re.sub(r"\b\d{8,10}:[A-Za-z0-9_-]{30,}\b", "REDACTED_TELEGRAM_TOKEN", text)
    print(text)
PY

  systemctl cat "$SERVICE" 2>/dev/null > snapshots/systemd/hermes-gateway.service || true
  find "$HERMES_HOME/skills" -maxdepth 2 -type f 2>/dev/null | sort > snapshots/hermes/skills.txt || true

  {
    echo "Hermes healthcheck for VPS nightly sync"
    echo "service.active=$(systemctl is-active "$SERVICE" 2>/dev/null || true)"
    echo "service.enabled=$(systemctl is-enabled "$SERVICE" 2>/dev/null || true)"
    echo "workspace.exists=$([ -d "$HERMES_WORKSPACE" ] && echo yes || echo no)"
    echo "hermes.home.exists=$([ -d "$HERMES_HOME" ] && echo yes || echo no)"
    echo "config.exists=$([ -f "$HERMES_HOME/config.yaml" ] && echo yes || echo no)"
    echo "env.present=$([ -f "$HERMES_HOME/.env" ] && echo present || echo absent)"
    echo "auth_json.present=$([ -f "$HERMES_HOME/auth.json" ] && echo present || echo absent)"
    echo "synced_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > snapshots/hermes/healthcheck.txt

  sh scripts/verify-no-secrets.sh

  git add snapshots
  if git diff --cached --quiet; then
    echo "No safe snapshot changes to push."
    return 0
  fi

  git commit -m "Nightly Hermes snapshot sync $(date -u +%Y-%m-%d)"
  git push origin main
}

exec 9>"$LOCK_FILE"
flock -n 9 || {
  echo "Another Hermes sync is already running."
  exit 1
}
run_sync
