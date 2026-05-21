#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
HOST="${HERMES_VDS_HOST:-178.104.60.170}"
USER="${HERMES_VDS_USER:-root}"
PORT="${HERMES_VDS_PORT:-22}"
KEY="${HERMES_VDS_KEY:-$HOME/.ssh/hermes-vds/hermes_vds_ed25519}"
SSH_OPTS="-i $KEY -p $PORT -o BatchMode=yes -o ConnectTimeout=10"

echo "Deploying copywriter agent to $USER@$HOST"

ssh $SSH_OPTS "$USER@$HOST" "install -d -o hermes -g hermes /home/hermes/.hermes/skills/copywriter-agent /srv/hermes/workspace/docs/copywriting"
scp $SSH_OPTS "$ROOT_DIR/deploy/hermes/skills/copywriter-agent/SKILL.md" "$USER@$HOST:/home/hermes/.hermes/skills/copywriter-agent/SKILL.md"
scp $SSH_OPTS "$ROOT_DIR"/deploy/hermes/workspace/docs/copywriting/* "$USER@$HOST:/srv/hermes/workspace/docs/copywriting/"
ssh $SSH_OPTS "$USER@$HOST" "chown -R hermes:hermes /home/hermes/.hermes/skills/copywriter-agent /srv/hermes/workspace/docs/copywriting && systemctl restart hermes-gateway.service && systemctl is-active hermes-gateway.service"

echo "Copywriter agent deployed."

