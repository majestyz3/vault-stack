#!/bin/bash

########################################################################

RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

log () {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp=$(date "+%b %d %H:%M:%S")
  echo ""

  case "$level" in
    ERROR)
      echo -e "${timestamp} ${RED}[ERROR]${NC} $message"
      ;;
    WARNING)
      echo -e "${timestamp} ${YELLOW}[WARNING]${NC} $message"
      ;;
    INFO)
      echo -e "${timestamp} ${CYAN}[INFO]${NC} $message"
      ;;
    *)
      echo -e "${timestamp} [UNKNOWN] $message"
      ;;
  esac

  echo ""

}

# log INFO "This is an info message."
# log WARNING "This is a warning message."
# log ERROR "This is an error message."


########################################################################

vault11 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault10-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault11.mac.example.com:8211 \
  vault $@
}

vault12 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault10-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault12.mac.example.com:8212 \
  vault $@
}

vault13 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault10-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault13.mac.example.com:8213 \
  vault $@
}

########################################################################

vault21 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault20-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault21.mac.example.com:8221 \
  vault $@
}

vault22 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault20-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault22.mac.example.com:8222 \
  vault $@
}

vault23 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault20-init.json| jq -r .root_token) \
  VAULT_ADDR=https://vault23.mac.example.com:8223 \
  vault $@
}

########################################################################

vault31 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault30-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault31.mac.example.com:8231 \
  vault $@
}

vault32 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault30-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault32.mac.example.com:8232 \
  vault $@
}

vault33 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault30-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault33.mac.example.com:8233 \
  vault $@
}

########################################################################

vault41 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault40-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault41.mac.example.com:8241 \
  vault $@
}

vault42 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault40-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault42.mac.example.com:8242 \
  vault $@
}

vault43 () {
  VAULT_SKIP_VERIFY=1 \
  VAULT_TOKEN=$(cat vault40-root-post-performance-replication.json| jq -r .token) \
  VAULT_ADDR=https://vault43.mac.example.com:8243 \
  vault $@
}

########################################################################
