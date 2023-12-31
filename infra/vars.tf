variable "gandi_api_key" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "sub_domain" {
  type        = string
  description = "Final domain is sub_domain.base_domain"
  default     = ""
}

variable "dkim_public_key" {
  type = string
}

variable "server_public_ip" {
  type = string
}
