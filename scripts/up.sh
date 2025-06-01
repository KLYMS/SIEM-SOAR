#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
DOT_ENV="$ROOT_DIR/dot.env"

source $SCRIPT_DIR/output.sh

# List of services
SERVICES=(wazuh graylog agents grafana velociraptor shuffle thehive-cortex)
NETWORK_STACK=(siem-stack shuffle thehive-cortex)

DOCKER_ARGS=()
for arg in "$@"; do
  DOCKER_ARGS+=("$arg")
done

ENV_FILES=()
COMPOSE_FILES=()
STARTED_SERVICES=()
for service in "${SERVICES[@]}"; do
  ENV_FILES+=("$ROOT_DIR/$service/.env")

  # skipping shuffle service in COMPOSE_FILES
  if [[ ("$service" == "shuffle") ]]; then
    continue
  fi

  # if [[ ("$service" == "shuffle") || ("$service" == "thehive-cortex") ]]; then
  #   continue
  # fi

  COMPOSE_FILE="$ROOT_DIR/$service/docker-compose.yml"
  if [[ -f "$COMPOSE_FILE" ]]; then
    COMPOSE_FILES+=("$COMPOSE_FILE")
    STARTED_SERVICES+=("$service")
  else
    warning "Docker Compose file not found for $service: $COMPOSE_FILE"
  fi
done

# setup the env
for service in "${SERVICES[@]}"; do
  SETUP_SCRIPT="$ROOT_DIR/$service/setup.sh"
  if [[ -x "$SETUP_SCRIPT" ]]; then
    info "Found setup.sh script in $service"
    bash "$SETUP_SCRIPT"
    success "Successfully setup the env for $service"
  # else
  #   warning "No setup.sh found or executable for $service"
  fi
done

info "Generating unified .env -> $DOT_ENV"
> "$DOT_ENV"

if [[ -f "$ROOT_DIR/versions.env" ]]; then
  grep -vE '^\s*#|^\s*$' "$ROOT_DIR/versions.env" >> "$DOT_ENV"
  echo "" >> "$DOT_ENV"
else
  warning "versions.env not found!"
fi

for ENV_FILE in "${ENV_FILES[@]}"; do
  info "Merging from $ENV_FILE to $DOT_ENV"
  if [[ "$ENV_FILE" == "$ROOT_DIR/shuffle/.env" ]]; then
      sed -E "s@^(SHUFFLE_APP_HOTLOAD_FOLDER|SHUFFLE_APP_HOTLOAD_LOCATION|SHUFFLE_FILE_LOCATION|DB_LOCATION)=\./@\1=$ROOT_DIR/shuffle/@" \
      "$ENV_FILE" | grep -vE '^\s*#|^\s*$' >> "$DOT_ENV"
  else
    if [[ -f "$ENV_FILE" ]]; then
      grep -vE '^\s*#|^\s*$' "$ENV_FILE" >> "$DOT_ENV"
      echo "" >> "$DOT_ENV"
    else
      warning "Env file $ENV_FILE not found, skipping..." 
    fi
  fi
done

COMPOSE_ARGS=()
for FILE in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=(-f "$FILE")
done

for net in "${NETWORK_STACK[@]}"; do
  if ! docker network ls --format '{{.Name}}' | grep -q "^$net$"; then
    info "Creating Docker network '$net'..."
    docker network create --driver bridge "$net" && success "Created Docker network '$net'"
  else
    warning "Docker network '$net' already exists. skipping"
  fi
done

success "Starting the containers: ${STARTED_SERVICES[*]} "
docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" up $DOCKER_ARGS


