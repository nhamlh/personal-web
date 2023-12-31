
terraform {
  required_providers {
    gandi = {
      source  = "go-gandi/gandi"
      version = "2.2.4"
    }
  }
}

provider "gandi" {
  key = var.gandi_api_key
}

module "dns" {
  source = "./modules/dns"

  server_public_ip   = var.aws == true ? module.aws[0].public_ip : var.server_public_ip
  base_domain        = var.base_domain
  sub_domain         = var.sub_domain
  dkim_policies      = var.dkim_policies
  spf_domains        = var.spf_domains
  additional_records = var.additional_records
}

module "aws" {
  count = var.aws ? 1 : 0

  source = "./modules/aws"

  ec2_public_key = var.ec2_public_key
  vpc_id         = var.vpc_id
}

output "server_public_ip" {
  value = var.aws == true ? module.aws[0].public_ip : var.server_public_ip
}
