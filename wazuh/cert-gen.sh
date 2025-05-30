#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker-compose -f "${SCRIPT_DIR}/generate-indexer-certs.yml" run --rm generator
