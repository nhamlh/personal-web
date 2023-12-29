
terraform {
  required_providers {
    gandi = {
      source  = "go-gandi/gandi"
      version = "2.2.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

provider "gandi" {
  key = var.gandi_api_key
}

provider "aws" {}

data "gandi_domain" "this" {
  name = var.domain_name
}

#################################
# DNS
#################################

resource "gandi_livedns_record" "a_records" {
  for_each = toset(["@", "blog", "mail"])
  name     = each.key
  ttl      = 300
  type     = "A"
  values   = [aws_eip.this.public_ip]
  zone     = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "mx" {
  name     = "@"
  ttl      = 300
  type     = "MX"
  values   = ["10 mail.${data.gandi_domain.this.name}"]
  zone     = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "domainkey" {
  name   = "stalwart._domainkey"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=DKIM1;k=rsa p=${tls_private_key.dkim.public_key_openssh}\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "spf" {
  name   = "@"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=spf1 a:mail.${data.gandi_domain.this.name} mx -all ra=postmaster\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "mail_spf" {
  name   = "mail"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=spf1 a -all ra=postmaster\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "dmarc" {
  name   = "_dmarc"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=DMARC1; p=none; rua=mailto:postmaster@${data.gandi_domain.this.name}; ruf=mailto:postmaster@${data.gandi_domain.this.name}\""]
  zone   = data.gandi_domain.this.name
}

#################################
# Linux server
#################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  #ami             = data.aws_ami.ubuntu.id
  ami              = "ami-0d96ec8a788679eb2"
  instance_type   = "t3.small"
  key_name        = aws_key_pair.owner.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "my_linux_box"
  }
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.this.id
}

resource "aws_key_pair" "owner" {
  key_name   = "owner"
  public_key = var.ec2_public_key
}

resource "aws_security_group" "this" {
  name        = "my_linux_box"
  description = "allow http and mail ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset([22, 80, 443, 8080, 25, 587, 465, 143, 993, 4190])
    content {
      description = "http"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_linux_box"
  }
}

#################################
# Ansible
#################################

# resource "ansible_playbook" "playbook" {
#   playbook   = "playbook.yml"
#   name       = aws_eip.this.public_ip
#   replayable = true

#   extra_vars = {
#     dkim_public_key  = tls_private_key.dkim.public_key
#     dkim_private_key = tls_private_key.dkim.private_key
#   }
# }

# resource "ansible_host" "this" {
#   name = aws_eip.this.public_ip

#   variables = {
#     ansible_user = "ubuntu"
#   }
# }

resource "tls_private_key" "dkim" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#################################
# Outputs
#################################

output "instance_ip" {
  value = aws_eip.this.public_ip
}

output "dkim_private_key" {
  value     = tls_private_key.dkim.private_key_openssh
  sensitive = true
}
