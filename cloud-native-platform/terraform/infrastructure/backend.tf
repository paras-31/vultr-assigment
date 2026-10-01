# Partial S3 backend. Real values come from backend.hcl generated after
# terraform/bootstrap apply. Vultr Object Storage is S3-compatible but is not
# Amazon S3, so several skip_* flags are required.
#
#   terraform init -backend-config=backend.hcl
#
# Credentials for the backend are AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
# from bootstrap outputs s3_access_key / s3_secret_key.

terraform {
  backend "s3" {}
}
