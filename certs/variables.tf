variable "domain" {
  type        = string
  description = "Domain"
  default     = "mac.example.com"
}

# Certificate Authority
variable "ca_country" {
  type        = string
  description = "Certificate Authority (CA) Country."
  default     = "US"
}

variable "ca_state" {
  type        = string
  description = "CA State."
  default     = "California"
}

variable "ca_locale" {
  type        = string
  description = "CA Locale."
  default     = "San Francisco"
}

variable "ca_org" {
  type        = string
  description = "CA Organization."
  default     = "HashiCorp"
}

variable "ca_ou" {
  type        = string
  description = "CA Organizational Unit."
  default     = "HashiCorp Network Operations Center"
}

variable "ca_common_name" {
  type        = string
  description = "CA Common Name (CN)."
  default     = "HashiCorp Certificate Authority"
}

variable "ca_cert_validity" {
  type        = number
  description = "CA Certificate validity period in hours."
  default     = 87600 # 10 years
}

# Certificate
variable "cert_country" {
  type        = string
  description = "Certificate Country."
  default     = "US"
}

variable "cert_state" {
  type        = string
  description = "Certificate State."
  default     = "California"
}

variable "cert_locale" {
  type        = string
  description = "Certificate Locale."
  default     = "San Francisco"
}

variable "cert_org" {
  type        = string
  description = "Certificate Organization."
  default     = "HashiCorp"
}

variable "cert_ou" {
  type        = string
  description = "Certificate Organizational Unit."
  default     = "HashiCorp Network Operations Center"
}

variable "cert_validity" {
  type        = number
  description = "Certificate validity period in hours."
  default     = 8760 # 1 year
}

