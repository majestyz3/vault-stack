#!/bin/bash
set -euo pipefail

# Load helper functions if available
if [ -f "functions.sh" ]; then
  . ./functions.sh
else
  log() { echo "$1 $2"; }
fi

# Load environment variables if present
if [ -f .env ]; then
  source .env
fi

DOMAIN=${DOMAIN:-mac.example.com}
HOSTS_FILE="/etc/hosts"

entries=(
  "127.0.0.1       traefik.${DOMAIN} whoami.${DOMAIN}"
  "127.0.0.1       vault10.${DOMAIN} vault11.${DOMAIN} vault12.${DOMAIN} vault13.${DOMAIN}"
  "127.0.0.1       vault20.${DOMAIN} vault21.${DOMAIN} vault22.${DOMAIN} vault23.${DOMAIN}"
  "127.0.0.1       vault30.${DOMAIN} vault31.${DOMAIN} vault32.${DOMAIN} vault33.${DOMAIN}"
  "127.0.0.1       vault40.${DOMAIN} vault41.${DOMAIN} vault42.${DOMAIN} vault43.${DOMAIN}"
)

for entry in "${entries[@]}"; do
  if ! grep -qF "$entry" "$HOSTS_FILE"; then
    log INFO "Adding missing hosts entry: $entry"
    echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
  else
    log INFO "Hosts entry already present: $entry"
  fi
done