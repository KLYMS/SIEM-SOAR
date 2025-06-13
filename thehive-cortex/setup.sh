#!/bin/bash

THEHIVE_CORTEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $THEHIVE_CORTEX_DIR/../scripts/output.sh
source $THEHIVE_CORTEX_DIR/cert-gen.sh


define_hostname(){
  SYSTEM_HOSTNAME=$(uname -n)
  info "Define the hostname used to connect to this server"
  read -p "Server Name (default: ${SYSTEM_HOSTNAME} ): " choice
  SERVICE_HOSTNAME=${choice:-${SYSTEM_HOSTNAME}}

}

ELASTICSEARCH_PASSWORD=$(cat /dev/urandom | LC_CTYPE=C tr -dc '[:alnum:]' | fold -w 64 | head -n 1)

## INIT THEHIVE CONFIGURATION
THEHIVE_INDEXFILE="$THEHIVE_CORTEX_DIR/thehive/config/index.conf"
THEHIVE_INDEXFILE_TEMPLATE="$THEHIVE_CORTEX_DIR/thehive/config/index.conf.template"

if [ -f ${THEHIVE_INDEXFILE} ]
then
  rm -f ${THEHIVE_INDEXFILE}
fi
sed -e "s/###CHANGEME_ELASTICSEARCH_PASSWORD###/$ELASTICSEARCH_PASSWORD/g" < $THEHIVE_INDEXFILE_TEMPLATE > $THEHIVE_INDEXFILE


THEHIVE_SECRETFILE="$THEHIVE_CORTEX_DIR/thehive/config/secret.conf"
if [ ! -f ${THEHIVE_SECRETFILE} ]
then
    cat > ${THEHIVE_SECRETFILE} << _EOF_
play.http.secret.key="$(cat /dev/urandom | LC_CTYPE=C tr -dc '[:alnum:]' | fold -w 64 | head -n 1)"
_EOF_
else
    STATUS=1
    warning "${THEHIVE_SECRETFILE} file already exists and has not been modified."
fi


## INIT CORTEX CONFIGURATION
CORTEX_INDEXFILE="$THEHIVE_CORTEX_DIR/cortex/config/index.conf"
CORTEX_INDEXFILE_TEMPLATE="$THEHIVE_CORTEX_DIR/cortex/config/index.conf.template"

if [ -f ${CORTEX_INDEXFILE} ]
then
    rm -f ${CORTEX_INDEXFILE}
fi
sed -e "s/###CHANGEME_ELASTICSEARCH_PASSWORD###/$ELASTICSEARCH_PASSWORD/g" < $CORTEX_INDEXFILE_TEMPLATE > $CORTEX_INDEXFILE


CORTEX_SECRETFILE="$THEHIVE_CORTEX_DIR/cortex/config/secret.conf"
if [ ! -f ${CORTEX_SECRETFILE} ]
then
    cat > ${CORTEX_SECRETFILE} << _EOF_
play.http.secret.key="$(cat /dev/urandom | LC_CTYPE=C tr -dc '[:alnum:]' | fold -w 64 | head -n 1)"
_EOF_
else
    STATUS=1
    warning "${CORTEX_SECRETFILE} file already exists and has not been modified."
fi


# CREATE .env FILE
ENV_FILE="$THEHIVE_CORTEX_DIR/.env"

define_hostname
> $ENV_FILE
cat >> ${ENV_FILE} << _EOF_
# elasticsearch_password
elasticsearch_password = "$ELASTICSEARCH_PASSWORD"

# Nginx configuration
nginx_server_name="${SERVICE_HOSTNAME}"
nginx_ssl_trusted_certificate="${NGINX_SSL_TRUSTED_CERTIFICATE_CONFIG}"

cortex_docker_job_directory="$THEHIVE_CORTEX_DIR/cortex/cortex-jobs"
_EOF_

success "Successfully generated the .env file"


