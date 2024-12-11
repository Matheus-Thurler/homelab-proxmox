terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
  # backend "s3" {
  #   bucket = "proxmox-state"
  #   key    = "terraform.tfstate"
  #   region = "placeholder"
  #
  #   endpoints = {
  #     s3 = "http://192.168.0.108:9000"
  #   }
  #
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  #   use_path_style              = true
  # }
}

# provider "proxmox" {
#   pm_api_url      = "https://192.168.0.10:8006/api2/json"
#   pm_tls_insecure = true
#   pm_api_token_id = "terraform-prov@pve!terraform"
#   pm_api_token_secret = "d43d3f91-eeed-4fcb-af32-8327002e7809"
#   pm_timeout = 600
# }
provider "proxmox" {
  pm_api_url      = var.providerp.pm_api_url
  pm_tls_insecure = var.providerp.pm_tls_insecure
  pm_api_token_id = var.providerp.pm_api_token_id
  pm_api_token_secret = var.providerp.pm_api_token_secret
  pm_timeout = var.providerp.pm_timeout
}

