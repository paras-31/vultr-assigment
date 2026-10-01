provider "vultr" {
  # Authenticate with VULTR_API_KEY in the environment.
  rate_limit  = 700
  retry_limit = 3
}
