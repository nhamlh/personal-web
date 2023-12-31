locals {
  domain      = var.sub_domain == "" ? data.gandi_domain.this.name : "${var.sub_domain}.${data.gandi_domain.this.name}"
  spf_include = join(" ", [for d in var.spf_domains : "include:${d}"])
}

data "gandi_domain" "this" {
  name = var.base_domain
}

resource "gandi_livedns_record" "main_record" {
  name   = var.sub_domain == "" ? "@" : var.sub_domain
  ttl    = 300
  type   = "A"
  values = [var.server_public_ip]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "a_records" {
  for_each = toset(["blog", "mail"])

  name   = var.sub_domain == "" ? each.key : "${each.key}.${var.sub_domain}"
  ttl    = 300
  type   = "A"
  values = [var.server_public_ip]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "mx" {
  name   = var.sub_domain == "" ? "@" : var.sub_domain
  ttl    = 300
  type   = "MX"
  values = [var.sub_domain == "" ? "10 mail.${data.gandi_domain.this.name}." : "10 mail.${var.sub_domain}.${data.gandi_domain.this.name}."]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "domainkey" {
  for_each = { for index, obj in var.dkim_policies : obj.selector => obj }

  name   = var.sub_domain == "" ? "${each.value.selector}._domainkey" : "${each.value.selector}._domainkey.${var.sub_domain}"
  ttl    = 300
  type   = "TXT"
  values = [each.value.value]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "spf" {
  name   = var.sub_domain == "" ? "@" : var.sub_domain
  ttl    = 300
  type   = "TXT"
  values = ["\"v=spf1 a:mail.${local.domain} ${local.spf_include} mx -all\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "mail_spf" {
  name   = var.sub_domain == "" ? "mail" : "mail.${var.sub_domain}"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=spf1 a -all ra=postmaster\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "dmarc" {
  name   = var.sub_domain == "" ? "_dmarc" : "_dmarc.${var.sub_domain}"
  ttl    = 300
  type   = "TXT"
  values = ["\"v=DMARC1; p=none; rua=mailto:postmaster@${local.domain}; ruf=mailto:postmaster@${local.domain}\""]
  zone   = data.gandi_domain.this.name
}

resource "gandi_livedns_record" "additional_records" {
  for_each = { for index, obj in var.additional_records : obj.name => obj }

  name   = var.sub_domain == "" ? each.value.name : "${each.value.name}.${var.sub_domain}"
  ttl    = 300
  type   = each.value.type
  values = each.value.values
  zone   = data.gandi_domain.this.name
}
