#!/bin/bash
# set -e

echo "[*] Starting Graylog wrapper setup..."

# Define paths
TRUSTSTORE="/usr/share/graylog/ssl/cacerts"
TRUSTSTORE_SOURCE="/opt/java/openjdk/lib/security/cacerts"
CERT_FILE="/usr/share/graylog/ssl/root-ca.pem"

# Copy original Java truststore
if [ ! -f "$TRUSTSTORE" ]; then
  echo "[*] Copying default cacerts to $TRUSTSTORE..."
  cp "$TRUSTSTORE_SOURCE" "$TRUSTSTORE"
else
  echo "[*] Truststore already exists at $TRUSTSTORE, skipping copy."
fi

# Import certificate if not already imported
if ! keytool -list -keystore "$TRUSTSTORE" -storepass changeit -alias wazuh_root_ca > /dev/null 2>&1; then
  echo "[*] Importing Wazuh root CA..."
  keytool -importcert -noprompt \
    -keystore "$TRUSTSTORE" \
    -storepass changeit \
    -alias wazuh_root_ca \
    -file "$CERT_FILE"
else
  echo "[*] Wazuh root CA already imported."
fi

# Restart Graylog service
echo "[*] Starting Graylog service..."
exec /usr/share/graylog/bin/graylogctl restart

