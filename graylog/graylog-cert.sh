#!/bin/bash

SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SSL_DIR/output.sh

info "Starting Graylog wrapper setup..."

# Define paths
TRUSTSTORE="/usr/share/graylog/ssl/cacerts"
TRUSTSTORE_SOURCE="/opt/java/openjdk/lib/security/cacerts"
CERT_FILE="/usr/share/graylog/ssl/root-ca.pem"

# Copy original Java truststore
if [ ! -f "$TRUSTSTORE" ]; then
  info "Copying default cacerts to $TRUSTSTORE..."
  cp "$TRUSTSTORE_SOURCE" "$TRUSTSTORE"
else
  warning "Truststore already exists at $TRUSTSTORE, skipping copy."
fi

# Import certificate if not already imported
if ! keytool -list -keystore "$TRUSTSTORE" -storepass changeit -alias wazuh_root_ca > /dev/null 2>&1; then
  info "Importing Wazuh root CA..."
  keytool -importcert -noprompt \
    -keystore "$TRUSTSTORE" \
    -storepass changeit \
    -alias wazuh_root_ca \
    -file "$CERT_FILE"
else
warning "Wazuh root CA already imported."
fi

# Restart Graylog service
success "Starting Graylog service..."
exec /usr/share/graylog/bin/graylogctl restart

