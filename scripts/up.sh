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

  # skipping shuffle service in COMPOSE_FILES
  if [[ "$service" == "shuffle" ]]; then
    continue
  fi

  COMPOSE_FILES+=("$ROOT_DIR/$service/docker-compose.yml")
done


echo "[*] Generating unified .env -> $DOT_ENV"
> "$DOT_ENV"

if [[ -f "$ROOT_DIR/versions.env" ]]; then
  grep -vE '^\s*#|^\s*$' "$ROOT_DIR/versions.env" >> "$DOT_ENV"
  echo "" >> "$DOT_ENV"
else
  echo "[*] Warning: versions.env not found!"
fi

for ENV_FILE in "${ENV_FILES[@]}"; do
  echo "[*] Merging from $ENV_FILE to $DOT_ENV"
  if [[ "$ENV_FILE" == "$ROOT_DIR/shuffle/.env" ]]; then
      sed -E "s@^(SHUFFLE_APP_HOTLOAD_FOLDER|SHUFFLE_APP_HOTLOAD_LOCATION|SHUFFLE_FILE_LOCATION|DB_LOCATION)=\./@\1=$ROOT_DIR/shuffle/@" \
      "$ENV_FILE" | grep -vE '^\s*#|^\s*$' >> "$DOT_ENV"
  else
    if [[ -f "$ENV_FILE" ]]; then
      grep -vE '^\s*#|^\s*$' "$ENV_FILE" >> "$DOT_ENV"
      echo "" >> "$DOT_ENV"
    else
      echo "[*] Warning: Env file $ENV_FILE not found, skipping..." 
    fi
  fi
done


COMPOSE_ARGS=()
for FILE in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=(-f "$FILE")
done

for net in siem-stack shuffle; do
  if ! docker network ls --format '{{.Name}}' | grep -q "^$net$"; then
    echo "[*] Creating Docker network '$net'..."
    docker network create --driver bridge "$net"
  else
    echo "[*] Docker network '$net' already exists."
  fi
done

docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" up "$@"


