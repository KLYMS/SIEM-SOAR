#!/bin/bash

THEHIVE_CORTEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $THEHIVE_CORTEX_DIR/../scripts/output.sh 2>/dev/null || true

DIRS=(cassandra cortex elasticsearch nginx thehive)

error "This action will completely reset the Thehive-cortex stack. All data will be lost!"
info "Cleaning folders in: ${DIRS[*]}"

for base in "${DIRS[@]}"; do
  BASE_PATH="$THEHIVE_CORTEX_DIR/$base"

  if [[ -d "$BASE_PATH" ]]; then
    info "Cleaning $base..."

    find "$BASE_PATH" -mindepth 1 -maxdepth 1 -type d | while read -r subdir; do
      # info "  Cleaning $subdir..."

      find "$subdir" -mindepth 1 \( \
        ! -name "application.conf" \
        ! -name "*.template" \
        ! -name "logback.xml" \
        ! -name ".gitkeep" \
      \) -exec sudo rm -rf {} +

      # success "  Cleaned: $subdir"
    done
      success "Cleaned: $base"
  else
    warning "Directory not found: $BASE_PATH"
  fi
done

info "Removing the contents of the .env file"
ENV_FILE="$THEHIVE_CORTEX_DIR/.env"

>$ENV_FILE 

success "Successfully removed the contents in Environment File"


