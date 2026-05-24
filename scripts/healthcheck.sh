#!/usr/bin/env sh
set -eu

HOST="${HERMES_VDS_HOST:-178.104.60.170}"
USER="${HERMES_VDS_USER:-root}"
PORT="${HERMES_VDS_PORT:-22}"
KEY="${HERMES_VDS_KEY:-$HOME/.ssh/hermes-vds/hermes_vds_ed25519}"
SERVICE="${HERMES_GATEWAY_SERVICE:-hermes-gateway.service}"
WORKSPACE="${HERMES_WORKSPACE:-/srv/hermes/workspace}"
HOME_DIR="${HERMES_HOME:-/home/hermes/.hermes}"

SSH="ssh -i $KEY -p $PORT -o BatchMode=yes -o ConnectTimeout=10"

echo "Hermes healthcheck for $USER@$HOST"
echo "service.active=$($SSH "$USER@$HOST" "systemctl is-active $SERVICE 2>/dev/null || true")"
echo "service.enabled=$($SSH "$USER@$HOST" "systemctl is-enabled $SERVICE 2>/dev/null || true")"
echo "workspace.exists=$($SSH "$USER@$HOST" "test -d '$WORKSPACE' && echo yes || echo no")"
echo "hermes.home.exists=$($SSH "$USER@$HOST" "test -d '$HOME_DIR' && echo yes || echo no")"
echo "config.exists=$($SSH "$USER@$HOST" "test -f '$HOME_DIR/config.yaml' && echo yes || echo no")"
echo "env.present=$($SSH "$USER@$HOST" "test -f '$HOME_DIR/.env' && echo present || echo absent")"
echo "auth_json.present=$($SSH "$USER@$HOST" "test -f '$HOME_DIR/auth.json' && echo present || echo absent")"
echo "hermes.version_hint=$($SSH "$USER@$HOST" "command -v hermes >/dev/null 2>&1 && hermes --version 2>/dev/null || python3 -m hermes --version 2>/dev/null || echo unknown")"
