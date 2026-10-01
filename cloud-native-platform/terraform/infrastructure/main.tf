locals {
  common_labels = {
    project     = var.project
    environment = var.environment
    "managed-by" = "terraform"
    owner       = var.owner
  }
}

resource "vultr_kubernetes" "cluster" {
  region             = var.region
  label              = var.cluster_label
  version            = var.kubernetes_version
  ha_controlplanes   = var.ha_control_planes
  enable_firewall    = var.enable_firewall

  node_pools {
    node_quantity = var.node_quantity
    plan          = var.node_plan
    label         = var.node_pool_label
    auto_scaler   = var.enable_node_autoscaler
    min_nodes     = var.autoscaler_min_nodes
    max_nodes     = var.autoscaler_max_nodes

    labels {
      key   = "project"
      value = local.common_labels.project
    }

    labels {
      key   = "environment"
      value = local.common_labels.environment
    }

    labels {
      key   = "managed-by"
      value = local.common_labels["managed-by"]
    }

    labels {
      key   = "owner"
      value = local.common_labels.owner
    }
  }
}

resource "vultr_container_registry" "app" {
  name   = var.registry_name
  region = var.region
  plan   = var.registry_plan
  public = false
}
