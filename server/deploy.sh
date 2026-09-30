#!/usr/bin/env bash
# Run on the server inside this folder:  bash deploy.sh
# Before running: put your NVIDIA key in .env as  NVIDIA_API_KEY=nvapi-...   (do it yourself, never in chat)
set -euo pipefail
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sudo sh
rnd(){ head -c 48 /dev/urandom | base64 | tr -dc a-z0-9 | head -c "$1"; }
touch .env
grep -q '^DASHBOARD_PASSWORD=' .env || printf "DASHBOARD_USER=admin\nDASHBOARD_PASSWORD=$(rnd 20)\nDASHBOARD_SECRET=$(rnd 32)\nAPI_SERVER_KEY=$(rnd 32)\n" >> .env
grep -q '^NVIDIA_API_KEY=nvapi-' .env || { echo "Add NVIDIA_API_KEY=nvapi-... to .env first"; exit 1; }
NV_MODEL=${NV_MODEL:-meta/llama-3.3-70b-instruct}
KEY=$(grep '^NVIDIA_API_KEY=' .env | cut -d= -f2-)
mkdir -p data searxng
sed "s/replace-at-setup/$(rnd 32)/" searxng.settings.yml > searxng/settings.yml
cat > data/config.yaml <<EOF
model:
  provider: custom
  default: $NV_MODEL
  base_url: https://integrate.api.nvidia.com/v1
  api_key: $KEY
EOF
D="sudo docker"
$D compose up -d
sleep 25
for a in $(ls agents); do
  $D exec hermes hermes profile create "$a" --clone --description "$(head -3 agents/$a/SOUL.md | tail -1)" || true
  sudo cp "agents/$a/SOUL.md" "data/profiles/$a/SOUL.md"
done
$D exec hermes hermes kanban init || true
echo "DONE. Dashboard: ssh -L 9119:localhost:9119 <user>@<server-ip>  then open http://localhost:9119 (password in .env)"
