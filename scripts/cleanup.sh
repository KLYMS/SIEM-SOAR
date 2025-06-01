#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
DOT_ENV="$ROOT_DIR/dot.env"

source $SCRIPT_DIR/output.sh

# List of services
SERVICES=(wazuh graylog agents grafana velociraptor shuffle thehive-cortex)
NETWORK_STACK=(siem-stack shuffle thehive-cortex)

DEL_ALL=false
DOCKER_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--del-all" ]]; then
    DEL_ALL=true
  else
    DOCKER_ARGS+=("$arg")
  fi
done

COMPOSE_FILES=()
for service in "${SERVICES[@]}"; do
  COMPOSE_FILES+=("$ROOT_DIR/$service/docker-compose.yml")
done

COMPOSE_ARGS=()
for FILE in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=(-f "$FILE")
done

if [[ "$DEL_ALL" == true ]]; then
  error "You are about to delete all persistent data related to stack"
  read -p "Are you sure you want to continue? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    warning "Aborted by user."
    exit 1
  fi
fi

if [[ "$DEL_ALL" == true ]]; then
  for service in "${SERVICES[@]}"; do
    CLEAN_SCRIPT="$ROOT_DIR/$service/clean.sh"
    if [[ -x "$CLEAN_SCRIPT" ]]; then
      info "Found cleaning script in $service"
      bash "$CLEAN_SCRIPT"
      success "Deleat all data from $service"
    else
      info "No clean.sh found or not executable for $service"
    fi
  done
  warning "Removing all the data in docker volumes and stoping the containers..."
  docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" down --volumes --remove-orphans $DOCKER_ARGS
else
  docker-compose "${COMPOSE_ARGS[@]}" --env-file "$DOT_ENV" down --remove-orphans $DOCKER_ARGS
fi

# removing the dot.env file
if [[ -f "$DOT_ENV" ]]; then
  info "Removing the combined env file $DOT_ENV file ..."
  rm -f "$DOT_ENV"
else
  warning "There is no combined env file $DOT_ENV file"
fi

# Remove the Docker network if it exists
for net in "${NETWORK_STACK[@]}"; do
  if docker network ls --format '{{.Name}}' | grep -q "^$net$"; then
    info "Removing Docker network '$net'..."
    docker network rm "$net" && success "Removed Docker network '$net'"
  else
    warning "Docker network '$net' does not exist. Skipping."
  fi
done


