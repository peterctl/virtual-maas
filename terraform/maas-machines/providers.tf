terraform {
  required_providers {
    maas = {
      source = "canonical/maas"
      version = "~>1.0"
    }
  }
}

provider "maas" {
  api_version = "2.0"
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}
