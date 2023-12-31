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

variable "aws" {
  type        = bool
  description = "(optional)"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "required when enable aws"
  default     = ""
}

variable "ec2_public_key" {
  type        = string
  description = "required when enable aws"
  default     = ""
}

variable "server_public_ip" {
  type        = string
  description = "required when disable aws (DNS only mode)"
  default     = ""
}

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
