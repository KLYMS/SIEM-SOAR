#!/bin/bash

GRAYLOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $GRAYLOG_DIR/../scripts/output.sh

GRAYLOG_CONTAINER=$(docker ps --filter "name=graylog" --format {{.ID}} | head -n1)
if [ -z "$GRAYLOG_CONTAINER" ]; then
  GRAYLOG_CONTAINER=$(docker ps --format "{{.Names}}" | grep -i graylog | grep -v datanode | head -n1)
fi

if [ -z "$GRAYLOG_CONTAINER" ]; then
  warning "Graylog container not found. Exiting."
  exit 1
fi

success "Found Graylog container: $GRAYLOG_CONTAINER"

info "Waiting for $GRAYLOG_CONTAINER container to be running..."
while [ "$(docker inspect "$GRAYLOG_CONTAINER" --format '{{.State.Running}}' 2>/dev/null)" != "true" ]; do
  sleep 1
done

info "Container is running. Executing /graylog-wrapper.sh inside the container..."
docker exec -u root -it "$GRAYLOG_CONTAINER" bash -c "/usr/share/graylog/ssl/graylog-cert.sh"

