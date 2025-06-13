# Certificate Authority
# ca private key
resource "tls_private_key" "ca-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ca cert
resource "tls_self_signed_cert" "ca-cert" {
  private_key_pem       = tls_private_key.ca-private-key.private_key_pem
  validity_period_hours = var.ca_cert_validity
  is_ca_certificate     = true

  subject {
    common_name         = "${var.domain} Demo Root Certificate Authority"
    country             = var.ca_country
    province            = var.ca_state
    locality            = var.ca_locale
    organization        = var.ca_org
    organizational_unit = var.ca_ou

  }
  allowed_uses = [

    "digital_signature",
    "key_encipherment",
    "data_encipherment",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
}

# wildcard private key
resource "tls_private_key" "wildcard_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# wildcard csr
resource "tls_cert_request" "wildcard_csr" {
  private_key_pem = tls_private_key.wildcard_private_key.private_key_pem

  subject {
    common_name         = "*.${var.domain}"
    country             = var.cert_country
    province            = var.cert_state
    locality            = var.cert_locale
    organization        = var.cert_org
    organizational_unit = var.cert_ou
  }

  dns_names = [
    "*.${var.domain}",
  ]

  ip_addresses = ["127.0.0.1"]
}

# wildcard cert
resource "tls_locally_signed_cert" "wildcard_cert" {
  cert_request_pem   = tls_cert_request.wildcard_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca-private-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca-cert.cert_pem

  is_ca_certificate = true

  validity_period_hours = var.cert_validity

  allowed_uses = [
    "digital_signature",
    "server_auth",
    "client_auth",

    "cert_signing",
    "crl_signing",
    "ocsp_signing"

  ]
}

resource "local_file" "ca_cert" {
  content         = tls_self_signed_cert.ca-cert.cert_pem
  filename        = "${path.module}/wildcard/ca.pem"
  file_permission = "0644"
}

resource "local_file" "wildcard_private_key" {
  content         = tls_private_key.wildcard_private_key.private_key_pem
  filename        = "${path.module}/wildcard/privkey.pem"
  file_permission = "0600"
}

resource "local_file" "wildcard_certificate" {
  content         = tls_locally_signed_cert.wildcard_cert.cert_pem
  filename        = "${path.module}/wildcard/certificate.pem"
  file_permission = "0644"
}

resource "local_file" "wildcard_fullchain" {
  content         = "${tls_locally_signed_cert.wildcard_cert.cert_pem}${tls_self_signed_cert.ca-cert.cert_pem}"
  filename        = "${path.module}/wildcard/fullchain.pem"
  file_permission = "0644"
}
