#!/bin/bash

THEHIVE_CORTEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_CERT_DIR="$THEHIVE_CORTEX_DIR/nginx/certs/"
CERT_FILE="${NGINX_CERT_DIR}/server.crt"
KEY_FILE="${NGINX_CERT_DIR}/server.key"
CA_FILE="${NGINX_CERT_DIR}/ca.pem"

source $THEHIVE_CORTEX_DIR/../scripts/output.sh


success "Generating self-signed certificate ..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/CN=${SERVER_NAME:-localhost}"

success "Self-signed certificate generated for ${SERVER_NAME:-localhost}."
