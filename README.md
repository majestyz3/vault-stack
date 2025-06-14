# vault-stack

This repo stands up four HashiCorp Vault Enterprise clusters in Docker. Each clsuter has 3 nodes, and uses raft integrated storage. The clusters are as follows:
1. [https://vault10.mac.example.com](https://vault10.mac.example.com)
2. [https://vault20.mac.example.com](https://vault20.mac.example.com)
3. [https://vault30.mac.example.com](https://vault30.mac.example.com)
4. [https://vault40.mac.example.com](https://vault40.mac.example.com)

`vault10` is configured as the Performnce Primary and DR Primary.
`vault20` is `vault10`'s DR Secondary.
`vault30` is configured as a Performance Secondary and DR Primary.
`vault40` is `vault30`'s DR Secondary. **Note that this has not been implemented yet.**

## Prerequisites

1. macOS.

2. Ability to edit `/etc/hosts` — `sudo vi /etc/hosts`.

3. Docker Desktop.

4. HashiCorp Vault CLI (Community Edition or Enterprise Edition).

5. Vault Enterprise License.

6. `jq`, `openssl`.

## Usage

1. Place the following entries in your `/etc/hosts` file.

```
127.0.0.1       traefik.mac.example.com whoami.mac.example.com
127.0.0.1       vault10.mac.example.com vault11.mac.example.com vault12.mac.example.com vault13.mac.example.com
127.0.0.1       vault20.mac.example.com vault21.mac.example.com vault22.mac.example.com vault23.mac.example.com
127.0.0.1       vault30.mac.example.com vault31.mac.example.com vault32.mac.example.com vault33.mac.example.com
127.0.0.1       vault40.mac.example.com vault41.mac.example.com vault42.mac.example.com vault43.mac.example.com
```

2. Clone the repo (or a fork of it).

```
mkdir -p ~/data && \
  cd ~/data && \
  git clone git@github.com:ykhemani-demo/vault-stack.git && \
  cd vault-stack
```

3. Obtain and place a Vault Enterprise license in `license/vault.hclic`. For example:

```
echo $VAULT_LICENSE > license/vault.hclic
```

4. Provision the demo environment.

```
./stack.sh
```

5. Add `certs/wildcard/ca.pem` to your trust store.

```
open certs/wildcard/ca.pem
```

This will open Keychain Access, where you can mark the CA Cert as trusted.

6. Connect to the DR Primary by opening [https://vault10.mac.example.com](https://vault10.mac.example.com) in your browser.

You may obtain the root token by running:

```
cat vault10-init.json | jq -r .root_token
```

7. Connect to the DR Secondary by opening [https://vault20.mac.example.com](https://vault20.mac.example.com) in your browser.

8. Clean up when you're done.

```
./unstack.sh
```

---
