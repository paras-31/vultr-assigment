locals {
  common_labels = {
    project        = var.project
    environment    = var.environment
    "managed-by"   = "terraform"
    owner          = var.owner
    purpose        = "terraform-remote-state"
  }
}

data "vultr_object_storage_cluster" "state" {
  filter {
    name   = "region"
    values = [var.object_storage_region]
  }
}

data "vultr_object_storage_tier" "state" {
  filter {
    name   = "slug"
    values = [var.object_storage_tier_slug]
  }
}

resource "vultr_object_storage" "tfstate" {
  cluster_id = tonumber(data.vultr_object_storage_cluster.state.id)
  tier_id    = tonumber(data.vultr_object_storage_tier.state.id)
  label      = var.object_storage_label

  # Bucket metadata is tracked in Terraform state. Do not enable object-lock
  # here: Vultr object-lock is not Terraform state locking, and it can block
  # overwriting terraform.tfstate.
  bucket {
    name              = var.state_bucket_name
    enable_versioning = var.enable_bucket_versioning
    enable_lock       = false
  }
}
