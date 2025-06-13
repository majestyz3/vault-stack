#!/bin/bash

# Vault configs should exist. Not generated as part of this script.


. ./functions.sh

# Determine repository directory for Docker mounts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TOP="${TOP:-$SCRIPT_DIR}"

log INFO "Starting stack.sh"

for i in 1 2; do
  for j in 1 2 3; do
    mkdir -p vault$i$j/audit
    mkdir -p vault$i$j/conf
    mkdir -p vault$i$j/data
    mkdir -p vault$i$j/plugins
    mkdir -p vault$i$j/snapshots
  done
done

log INFO "Starting cert_factory (terraform) to generate certificates."
docker-compose up -d cert_factory
sleep 5

log INFO "Certificates:"
ls -l certs/wildcard
if [ ! -f certs/wildcard/privkey.pem ]; then
  log ERROR "Certificate generation failed. See cert_factory container logs."
  exit 1
fi

log INFO "Starting the rest of the containers."
docker-compose up -d 

sleep 2

log INFO "Initializing Vault cluster vault10."
vault11 operator init -key-threshold=1 -key-shares=1 -format=json | tee vault10-init.json

sleep 2

log INFO "Setting VAULT_SEAL_KEY and VAULT_TOKEN for vault10."
export VAULT_SEAL_KEY=$(cat vault10-init.json | jq -r ".unseal_keys_b64[]")
export VAULT_TOKEN=$(cat vault10-init.json | jq -r .root_token)

. ./functions.sh

log INFO "Unsealing vault11."
vault11 operator unseal $VAULT_SEAL_KEY

log INFO "Enabling audit logging."
vault11 audit enable file \
  file_path=/vault/audit/audit.log && \
  vault11 audit enable -path=raw file \
    file_path=/vault/audit/raw.log log_raw=true

sleep 2
log INFO "Unsealing vault12."
vault12 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault13."
vault13 operator unseal $VAULT_SEAL_KEY

sleep 5
log INFO "Getting raft peers for vault10."
vault11 operator raft list-peers

###########################################################

log INFO "Initializing Vault cluster vault20."
vault21 operator init -key-threshold=1 -key-shares=1 -format=json | tee vault20-init.json

sleep 2

log INFO "Setting VAULT_SEAL_KEY and VAULT_TOKEN for vault20."
export VAULT_SEAL_KEY=$(cat vault20-init.json | jq -r ".unseal_keys_b64[]")
export VAULT_TOKEN=$(cat vault20-init.json | jq -r .root_token)

log INFO "Unsealing vault21."
vault21 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault22."
vault22 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault23."
vault23 operator unseal $VAULT_SEAL_KEY

sleep 5
log INFO "Getting raft peers for vault20."
VAULT_TOKEN=$(cat vault20-init.json | jq -r .root_token) vault21 operator raft list-peers

###########################################################

log INFO "Enable (primary) DR replication on vault10."
vault11 write -f sys/replication/dr/primary/enable

log INFO "Generate secondary DR Replication token on DR Primary (vault10)."
vault11 write -format=json sys/replication/dr/primary/secondary-token id="dr-secondary" | tee vault10-dr-secondary-token.json

sleep 10
log INFO "Enable (secondary) DR replication vault20."
vault21 write sys/replication/dr/secondary/enable token=$(cat vault10-dr-secondary-token.json | jq -r .wrap_info.token) ca_file=/run/secrets/wildcard_ca_cert

###########################################################

log INFO "Please add certs/wildcard/ca.pem to your trust store."
