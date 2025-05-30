#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
DOT_ENV="$ROOT_DIR/dot.env"

# List of services
SERVICES=(wazuh graylog agents grafana velociraptor shuffle)

ENV_FILES=()
COMPOSE_FILES=()

for service in "${SERVICES[@]}"; do
  ENV_FILES+=("$ROOT_DIR/$service/.env")
  COMPOSE_FILES+=("$ROOT_DIR/$service/docker-compose.yml")
done


> "$DOT_ENV"
for ENV_FILE in "${ENV_FILES[@]}"; do
  if [[ -f "$ENV_FILE" ]]; then
    echo "[*] From $ENV_FILE" >> "$DOT_ENV"
    grep -vE '^\s*#|^\s*$' "$ENV_FILE" >> "$DOT_ENV"
    echo "" >> "$DOT_ENV"
  else
    echo "[*] Warning: Env file $ENV_FILE not found, skipping..."
  fi
done


COMPOSE_ARGS=()
for FILE in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=(-f "$FILE")
done


if ! docker network ls --format '{{.Name}}' | grep -q '^siem-stack$'; then
  echo "[*] Creating Docker network 'siem-stack'..."
  docker network create --driver bridge siem-stack
else
  echo "[*] Docker network 'siem-stack' already exists."
fi

docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" up "$@"

