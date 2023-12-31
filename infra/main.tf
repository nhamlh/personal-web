
provider "gandi" {
  key = var.gandi_api_key
}

module "dns" {
  source = "./modules/dns"

  server_public_ip = var.server_public_ip
  base_domain      = var.base_domain
  sub_domain       = var.sub_domain
  dkim_policies = [
    { selector = "stalwart", value = "\"v=DKIM1;k=rsa;p=${var.dkim_public_key}\"" },
    { selector = "mailjet", value = "\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC35cALosfK5yNaeuH1fwSEey4d2GEqc9b0DaUW7BbfB1Unsces788FvieUZ3hyrOObSXyn9AhTRhLJmq9Jy+jR3pFlKVMPwv0G62Tzh6YvuE6Qsih7Ck0LUyowcDzRwH0+QMJJS/UO6cXe7WGZY9v1FEVJqmHCvHVtt5JYny01vwIDAQAB\"" },
  ]

  spf_domains = ["spf.mailjet.com"]

  additional_records = [
    # Mailjet domain validation
    {
      name   = "mailjet._68546c1f"
      type   = "TXT"
      values = ["68546c1f102bf5ed1ab21541c8c3e387"]
    }
  ]
}

module "aws" {
  source = "./modules/aws"

  ec2_public_key = var.ec2_public_key
  vpc_id         = var.vpc_id
}

output "server_public_ip" {
  value = aws.outputs.public_ip
}
