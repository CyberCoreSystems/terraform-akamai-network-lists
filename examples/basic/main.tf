terraform {
  required_version = ">= 1.6"
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = ">= 10.0, < 11.0"
    }
  }
}

provider "akamai" {
  # EdgeGrid credentials. These REPLACE_WITH_* strings are deliberately not
  # secret-shaped: real-looking placeholders trip entropy-based secret scanners
  # (checkov CKV_SECRET_6) in every downstream repo that vendors this example.
  config {
    host         = "REPLACE_WITH_YOUR_EDGEGRID_HOST.luna.akamaiapis.net"
    access_token = "REPLACE_WITH_YOUR_ACCESS_TOKEN"
    client_token = "REPLACE_WITH_YOUR_CLIENT_TOKEN"
    # Real EdgeGrid values come from ~/.edgerc or AKAMAI_* env vars.
    # checkov:skip=CKV_SECRET_6: documented placeholder, not a credential
    client_secret = "REPLACE_WITH_YOUR_CLIENT_SECRET"
  }
}

module "network_lists" {
  source = "../../"

  contract_id = "ctr_C-0000000"
  group_id    = "grp_000000"

  network_lists = {
    # Deny-by-default IP blocklist (REPLACE — Terraform owns the contents).
    ip_blocklist = {
      name        = "iacbazaar-ip-blocklist"
      type        = "IP"
      description = "Known-bad IPs and CIDRs."
      entries     = ["198.51.100.0/24", "203.0.113.7"]
    }

    # Geo blocklist by ISO country code.
    geo_blocklist = {
      name        = "iacbazaar-geo-blocklist"
      type        = "GEO"
      description = "Embargoed / high-abuse regions."
      entries     = ["KP", "RU"]
    }
  }

  # Stage contents only in the example; flip on with notification emails to push live.
  activate = false
}

output "network_list_ids" {
  value = module.network_lists.network_list_ids
}
