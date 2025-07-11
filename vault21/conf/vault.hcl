# raft storage
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-21"

  retry_join {
    leader_api_addr     = "https://vault21.mac.example.com:8200"
    leader_ca_cert_file = "/run/secrets/wildcard_ca_cert"
    tls_cert_file       = "/run/secrets/wildcard_cert"
    tls_key_file        = "/run/secrets/wildcard_privkey"
  }

  retry_join {
    leader_api_addr     = "https://vault22.mac.example.com:8200"
    leader_ca_cert_file = "/run/secrets/wildcard_ca_cert"
    tls_cert_file       = "/run/secrets/wildcard_cert"
    tls_key_file        = "/run/secrets/wildcard_privkey"
  }

  retry_join {
    leader_api_addr     = "https://vault23.mac.example.com:8200"
    leader_ca_cert_file = "/run/secrets/wildcard_ca_cert"
    tls_cert_file       = "/run/secrets/wildcard_cert"
    tls_key_file        = "/run/secrets/wildcard_privkey"
  }
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/run/secrets/wildcard_fullchain"
  tls_key_file  = "/run/secrets/wildcard_privkey"
}

api_addr     = "https://vault20.mac.example.com:8200"
cluster_addr = "https://vault21.mac.example.com:8201"

cluster_name = "vault"

