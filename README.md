# vault-stack

This repo stands up two HashiCorp Vault Enterprise clusters and configures DR Replication, setting one as a primary and the other as a secondary.

## Usage

1. Place the following entries in your `/etc/hosts` file.

```
127.0.0.1       traefik.mac.example.com whoami.mac.example.com
127.0.0.1       vault10.mac.example.com vault11.mac.example.com vault12.mac.example.com vault13.mac.example.com
127.0.0.1       vault20.mac.example.com vault21.mac.example.com vault22.mac.example.com vault23.mac.example.com
127.0.0.1       vault30.mac.example.com vault31.mac.example.com vault32.mac.example.com vault33.mac.example.com
127.0.0.1       vault40.mac.example.com vault41.mac.example.com vault42.mac.example.com vault43.mac.example.com
```

2. Install and enable Docker Desktop.

3. Clone the repo (or a fork of it).

```
mkdir -p ~/data && \
  cd ~/data && \
  git clone git@github.com:ykhemani-demo/vault-stack.git && \
  cd vault-stack
```

4. Obtain and place a Vault Enterprise license in `license/vault.hclic`.

5. Build the demo.

```
. ./functions.sh && \
  ./stack.sh
```

6. Add `certs/wildcard/ca.pem` to your trust store.

7. Open [https://vault10.mac.example.com](https://vault10.mac.example.com) in your browser.

---
