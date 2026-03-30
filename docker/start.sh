#!/usr/bin/env bash
# From repo root: bash docker/start.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ENV_FILE="$ROOT/docker/.env"
ENV_EXAMPLE="$ROOT/docker/.env.example"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Creating docker/.env from .env.example..."
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "Edit docker/.env if needed."
fi

docker compose -f docker/docker-compose.yml --env-file docker/.env up --build -d
echo "App: http://localhost:8080  |  Adminer: http://localhost:5050"
