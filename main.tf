
terraform {
  required_providers {
    gandi = {
      source = "go-gandi/gandi"
      version = "2.2.4"
    }
  }
}

provider "gandi" {
  key = var.gandi_api_key
}

data "gandi_domain" "this" {
    name = "nhamlh.me"
}

resource "gandi_livedns_record" "test" {
    name = "test"
    ttl = 300
    type = "A"
    values = ["1.2.3.4"]
    zone = data.gandi_domain.this.name
}
