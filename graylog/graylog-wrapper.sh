#!/bin/bash

GRAYLOG_CONTAINER=$(docker ps --filter "name=graylog" --format {{.ID}} | head -n1)

if [ -z "$GRAYLOG_CONTAINER" ]; then
  GRAYLOG_CONTAINER=$(docker ps --format "{{.Names}}" | grep -i graylog | grep -v datanode | head -n1)
fi

if [ -z "$GRAYLOG_CONTAINER" ]; then
  echo "Graylog container not found. Exiting."
  exit 1
fi

echo "Found Graylog container: $GRAYLOG_CONTAINER"

echo "Waiting for $GRAYLOG_CONTAINER container to be running..."
while [ "$(docker inspect "$GRAYLOG_CONTAINER" --format '{{.State.Running}}' 2>/dev/null)" != "true" ]; do
  sleep 1
done

echo "Container is running. Executing /graylog-wrapper.sh inside the container..."

docker exec -u root -it "$GRAYLOG_CONTAINER" bash -c "/usr/share/graylog/ssl/graylog-cert.sh"

