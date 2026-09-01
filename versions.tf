terraform {
  required_version = ">= 1.6"

  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = ">= 10.0, < 11.0"
    }
  }
}
