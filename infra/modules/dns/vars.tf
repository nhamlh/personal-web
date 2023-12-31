
variable "server_public_ip" {}
variable "base_domain" {}
variable "sub_domain" {}

variable "dkim_policies" {
  description = "Setup DKIM policies for secure email delivery"
  type = list(object({
    selector = string
    value    = string
  }))
}

variable "spf_domains" {
  description = "Setup SPF policies for secure email delivery"
  type        = list(string)
}

variable "additional_records" {
  type = list(object({
    type   = string
    name   = string
    values = list(string)
  }))
}
