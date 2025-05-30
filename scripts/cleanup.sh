#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
DOT_ENV="$ROOT_DIR/dot.env"

# List of services
SERVICES=(wazuh graylog agents grafana velociraptor shuffle)

COMPOSE_FILES=()
for service in "${SERVICES[@]}"; do
  COMPOSE_FILES+=("$ROOT_DIR/$service/docker-compose.yml")
done

COMPOSE_ARGS=()
for FILE in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=(-f "$FILE")
done

docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" down --volumes --remove-orphans

#removing the dot.env file
if [[ -f "$DOT_ENV" ]]; then
  echo "[*] Removing the combined env file $DOT_ENV file ..."
  rm "$DOT_ENV"
else
  echo "[*] Warning: There is no combined env file $DOT_ENV file ..."

# Remove the Docker network if it exists
if docker network ls --format '{{.Name}}' | grep -q '^siem-stack$'; then
  echo "Removing Docker network 'siem-stack'..."
  docker network rm siem-stack
else
  echo "Docker network 'siem-stack' does not exist. Skipping."
fi
