#!/bin/bash

# Vault configs should exist. Not generated as part of this script.

. ./functions.sh

log INFO "Starting stack.sh"

for i in 1 2 3 4; do
  for j in 1 2 3; do
    mkdir -p vault$i$j/audit
    mkdir -p vault$i$j/conf
    mkdir -p vault$i$j/data
    mkdir -p vault$i$j/plugins
    mkdir -p vault$i$j/snapshots
  done
done

log INFO "Starting pre-flight check."
ERROR=0
if [ ! -f license/vault.hclic ]
then
  log ERROR "The Vault license file doesn't exist. Please place the Vault license in license/vault.hclic."
  ERROR=1
fi

log INFO "Validating Vault license."
vault license inspect license/vault.hclic

if [ $? -ne 0 ]
then
  log ERROR "The Vault license check failed."
  ERROR=1
else
  log INFO "Vault license is valid."
fi

log INFO "Checking that Vault configurations exist."
for i in 1 2
do
  for j in 1 2 3
  do
    file_check="vault${i}${j}/conf/vault.hcl"
    if [ ! -f ${file_check} ]
    then
      log ERROR "Vault configuration file ${file_check} does not exist."
      ERROR=1
    fi
  done
done

if [ "${ERROR}" -ne "0" ]
then
  log INFO "Fix these errors bruh."
  exit $ERROR
fi

log INFO "Finished pre-flight check."

log INFO "Starting cert_factory (terraform) to generate certificates."
docker-compose up -d cert_factory
sleep 5

log INFO "Certificates:"
ls -l certs/wildcard

KEY_MOD=$(openssl rsa -noout -modulus -in "$KEY" | openssl md5)
CERT_MOD=$(openssl x509 -noout -modulus -in "$CERT" | openssl md5)

if [ "$CERT_MOD" == "$KEY_MOD" ]; then
  log INFO "[OK] Certificate and private key match."
else
  log ERROR "[FAIL] Certificate and private key DO NOT match."
  ERROR=1
fi

openssl verify -CAfile ${CA_CERT} ${CERT}

if [ $? -ne 0 ]
then
  log ERROR "There was a problem validating that the certificate ${CERT} was issued by the CA with certificate ${CA_CERT}."
  ERROR=1
else
  log INFO "The certificate is valid."
fi

if [ "${ERROR}" -ne "0" ]
then
  log INFO "Fix these errors bruh."
  exit $ERROR
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

log INFO "Initializing Vault cluster vault30."
vault31 operator init -key-threshold=1 -key-shares=1 -format=json | tee vault30-init.json

sleep 2

log INFO "Setting VAULT_SEAL_KEY and VAULT_TOKEN for vault30."
export VAULT_SEAL_KEY=$(cat vault30-init.json | jq -r ".unseal_keys_b64[]")
export VAULT_TOKEN=$(cat vault30-init.json | jq -r .root_token)

log INFO "Unsealing vault31."
vault31 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault32."
vault32 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault33."
vault33 operator unseal $VAULT_SEAL_KEY

sleep 5
log INFO "Getting raft peers for vault30."
VAULT_TOKEN=$(cat vault30-init.json | jq -r .root_token) vault31 operator raft list-peers

###########################################################

log INFO "Initializing Vault cluster vault40."
vault41 operator init -key-threshold=1 -key-shares=1 -format=json | tee vault40-init.json

sleep 2

log INFO "Setting VAULT_SEAL_KEY and VAULT_TOKEN for vault40."
export VAULT_SEAL_KEY=$(cat vault40-init.json | jq -r ".unseal_keys_b64[]")
export VAULT_TOKEN=$(cat vault40-init.json | jq -r .root_token)

log INFO "Unsealing vault41."
vault41 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault42."
vault42 operator unseal $VAULT_SEAL_KEY

sleep 2
log INFO "Unsealing vault43."
vault43 operator unseal $VAULT_SEAL_KEY

sleep 5
log INFO "Getting raft peers for vault40."
VAULT_TOKEN=$(cat vault40-init.json | jq -r .root_token) vault41 operator raft list-peers

###########################################################

log INFO "Enable (primary) DR replication on vault10."
vault11 write -f sys/replication/dr/primary/enable

log INFO "Generate secondary DR Replication token on DR Primary (vault10)."
vault11 write -format=json sys/replication/dr/primary/secondary-token id="dr-secondary" | tee vault10-dr-secondary-token.json

sleep 10
log INFO "Enable (secondary) DR replication vault20."
vault21 write sys/replication/dr/secondary/enable token=$(cat vault10-dr-secondary-token.json | jq -r .wrap_info.token) ca_file=/run/secrets/wildcard_ca_cert

###########################################################

sleep 5
log INFO "Enable (primary) Performance replication on vault10."
vault11 write -address=https://vault10.$DOMAIN -f sys/replication/performance/primary/enable

sleep 5
log INFO "Generate secondary Primary Replication token on Performance Primary (vault10)."
vault11 write -format=json -address=https://vault10.$DOMAIN sys/replication/performance/primary/secondary-token id=secondary | tee vault10-performance-primary-token.json

sleep 10
log INFO "Enable (secondary) Performance Replication on vault30."
vault31 write sys/replication/performance/secondary/enable token=$(cat vault10-performance-primary-token.json | jq -r .wrap_info.token) ca_file=/run/secrets/wildcard_ca_cert

###########################################################

# To do -- need to generate root for vault30 since it became a Performance Secondary before we can do this.

# log INFO "Enable (primary) DR replication on vault30."
# vault31 write -f sys/replication/dr/primary/enable

# log INFO "Generate secondary DR Replication token on DR Primary (vault30)."
# vault31 write -format=json sys/replication/dr/primary/secondary-token id="dr-secondary" | tee vault30-dr-secondary-token.json

# sleep 10
# log INFO "Enable (secondary) DR replication on vault40."
# vault41 write sys/replication/dr/secondary/enable token=$(cat vault30-dr-secondary-token.json | jq -r .wrap_info.token) ca_file=/run/secrets/wildcard_ca_cert

###########################################################

log INFO "Enable LDAP auth."
vault11 auth enable ldap

log INFO "Configure LDAP auth."
vault11 write auth/ldap/config \
  binddn="cn=admin,dc=example,dc=com" \
  bindpass='password' \
  userattr='uid' \
  url="ldaps://openldap.$DOMAIN" \
  userdn="ou=users,dc=example,dc=com" \
  groupdn="ou=users,dc=example,dc=com" \
  groupattr="groupOfNames" \
  certificate=@./certs/wildcard/ca.pem \
  insecure_tls=true \
  starttls=true

log INFO "Configure vault ldap engineers group"
vault11 write auth/ldap/groups/engineers policies=engineers

log INFO "Write Vault admin policy"
vault11 policy write admin -<<EOF
# full admin rights
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

log INFO "Configure vault admin user zarkesh"
vault11 write auth/ldap/users/zarkesh \
  policies=zarkesh,admin

###########################################################

log INFO "Please add certs/wildcard/ca.pem to your trust store."

log INFO "Finished stack.sh"
exit 0
