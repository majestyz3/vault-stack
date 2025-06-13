# vault-stack

This repo stands up two HashiCorp Vault Enterprise clusters and configures DR Replication, setting one as a primary and the other as a secondary.

## Usage

1. Install and enable Docker Desktop.

2. Clone the repo (or a fork of it).

```
mkdir -p ~/data && \
  cd ~/data && \
  git clone git@github.com:ykhemani-demo/vault-stack.git && \
  cd vault-stack
```

3. Obtain and place a Vault Enterprise license in `license/vault.hclic`.

4. Build the demo.

```
. ./functions.sh && \
  ./stack.sh
```

---
