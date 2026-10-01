output "object_storage_id" {
  description = "Object Storage subscription ID."
  value       = vultr_object_storage.tfstate.id
}

output "object_storage_region" {
  description = "Region of the Object Storage subscription."
  value       = vultr_object_storage.tfstate.region
}

output "object_storage_hostname" {
  description = "S3-compatible hostname (no scheme). Use this as the backend endpoint host."
  value       = vultr_object_storage.tfstate.s3_hostname
}

output "state_bucket_name" {
  description = "Bucket that stores Terraform remote state."
  value       = var.state_bucket_name
}

output "s3_access_key" {
  description = "S3 access key for the Object Storage subscription. Export as AWS_ACCESS_KEY_ID."
  value       = vultr_object_storage.tfstate.s3_access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "S3 secret key for the Object Storage subscription. Export as AWS_SECRET_ACCESS_KEY."
  value       = vultr_object_storage.tfstate.s3_secret_key
  sensitive   = true
}

output "backend_hcl_example" {
  description = "Copy into terraform/infrastructure/backend.hcl after substituting nothing else. Hostname is filled from this stack."
  value       = <<-EOT
    bucket                      = "${var.state_bucket_name}"
    key                         = "infrastructure/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    endpoints = {
      s3 = "https://${vultr_object_storage.tfstate.s3_hostname}"
    }
  EOT
}

output "common_labels" {
  description = "Standard labels used by this project."
  value       = local.common_labels
}
