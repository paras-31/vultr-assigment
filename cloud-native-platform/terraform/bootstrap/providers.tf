provider "vultr" {
  # Authenticate with VULTR_API_KEY in the environment.
  # Never commit the API key.
  rate_limit  = 700
  retry_limit = 3
}
