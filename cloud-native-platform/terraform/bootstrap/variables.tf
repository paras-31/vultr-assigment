variable "object_storage_region" {
  description = "Vultr region used to look up the Object Storage cluster (for example ewr, sjc, ams)."
  type        = string
  default     = "ewr"
}

variable "object_storage_tier_slug" {
  description = "Object Storage billing tier slug. Confirm with: vultr-cli object-storage tier list"
  type        = string
  default     = "tier_010k_5000m"
}

variable "object_storage_label" {
  description = "Human-readable label for the Object Storage subscription."
  type        = string
  default     = "cnp-tfstate"
}

variable "state_bucket_name" {
  description = "S3-compatible bucket that will hold Terraform remote state. Must be globally unique within the subscription."
  type        = string
  default     = "cnp-terraform-state"
}

variable "enable_bucket_versioning" {
  description = "Enable object versioning so previous terraform.tfstate versions can be recovered."
  type        = bool
  default     = true
}

variable "project" {
  description = "Project name used in labels and documentation."
  type        = string
  default     = "cloud-native-platform"
}

variable "environment" {
  description = "Environment name used in labels."
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner label for assignment attribution."
  type        = string
  default     = "devops-assignment"
}
