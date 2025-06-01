#!/bin/bash

SHUFFLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SHUFFLE_DIR/../scripts/output.sh

DIRS=(shuffle-apps shuffle-database shuffle-files)

error "This action will completely reset the Shuffle stack. All data will be lost!"
info "Cleaning folders in: ${DIRS[*]}"

for dir in "${DIRS[@]}"; do
    full_path="$SHUFFLE_DIR/$dir"
    info "Cleaning: $dir"
    if [[ -d "$full_path" ]]; then
        # info "Cleaning $full_path"
        find "$full_path" -mindepth 1 \( \
          ! -name ".gitkeep" \
        \) -exec rm -rf {} +
        success "Cleaned: $dir"
    else
        warning "Directory not found: $dir"
    fi
done

success "Cleaned folders in: ${DIRS[*]}"


