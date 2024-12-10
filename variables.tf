variable "providerp" {
  type = object({
  pm_api_url      = string
  pm_tls_insecure = bool
  pm_api_token_id = string
  pm_api_token_secret = string
  pm_timeout = number
  })
}