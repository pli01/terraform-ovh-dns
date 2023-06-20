terraform {
  required_providers {
    ovh = {
      source = "ovh/ovh"
    }
  }
  required_version = ">= 0.15"

  # Use http gitlab tfstate
  #  backend "http" {
  #    address = "https://gitlab.mydomain/api/v4/projects/ID/terraform/state/tfstate"
  #  }

}

variable "config" {
  description = "config.yml file"
  type        = string
  default     = "config.yml"
  #
  # yaml config file format
  # 
  #domain.com:
  #  app1:
  #    fieldtype: "A"
  #    ttl: 600
  #    target: "192.168.1.1"
  #  app2:
  #    fieldtype: "A"
  #    ttl: 120
  #    target: "192.168.2.2"
  #  app3.test:
  #    fieldtype: "A"
  #    ttl: 120
  #    target: "192.168.2.2"
}

locals {
  # default values
  default_ttl       = 600
  default_fieldtype = "A"

  # load config yaml file
  config = yamldecode(file("${path.module}/${var.config}"))

  # convert to list of record  map
  zone_config = distinct(flatten([for zone, value in local.config : [
    for subdomain, record in value : {
      "${subdomain}.${zone}" = merge(record, {
        subdomain : subdomain,
        zone : zone,
        ttl : contains(keys(record), "ttl") ? record.ttl : local.default_ttl
      })
    }
    ]
    ]
  ))

  # last steps: convert to map of records
  zone_record = { for k in local.zone_config : keys(k)[0] => values(k)[0] }

  # zone record will have this structure
  #  zone_record = {
  #    "app1.domain.com" = {
  #      fieldtype = "A"
  #      subdomain = "app1"
  #      target    = "192.168.1.1"
  #      ttl       = "600"
  #      zone      = "domain.com"
  #    }
  #    "app2.domain.com" = {
  #      fieldtype = "A"
  #      subdomain = "app2"
  #      target    = "192.168.1.2"
  #      ttl       = "600"
  #      zone      = "domain.com
  #    }
  #    "app3.test.domain.com" = {
  #      fieldtype = "A"
  #      subdomain = "app3.test"
  #      target    = "192.168.1.3"
  #      ttl       = "120"
  #      zone      = "domain.com"
  #    }
  #  }
}

#
# ovh domaine zone record
#
resource "ovh_domain_zone_record" "zone_record" {
  for_each  = local.zone_record

  fieldtype = each.value.fieldtype
  subdomain = each.value.subdomain
  target    = each.value.target
  ttl       = each.value.ttl
  zone      = each.value.zone
}
