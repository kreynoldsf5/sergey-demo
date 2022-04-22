terraform {
  required_version = ">= 0.15"
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.7"
    }
  }
}

provider "volterra" {
  api_p12_file = "${path.root}/${var.api_p12_file}"
  url          = var.api_url
}
