variable "region" {
  description = "Vultr region for VKE and the container registry."
  type        = string
  default     = "ewr"
}

variable "kubernetes_version" {
  description = "VKE version string. Must be 1.36.x. Confirm with GET /v2/kubernetes/versions."
  type        = string
  default     = "v1.36.2+1"

  validation {
    condition     = can(regex("^v1\\.36\\.", var.kubernetes_version))
    error_message = "kubernetes_version must be a VKE 1.36.x string such as v1.36.2+1. Do not use 1.37 unless compatibility is verified."
  }
}

variable "cluster_label" {
  description = "VKE cluster label."
  type        = string
  default     = "cnp-vke"
}

variable "ha_control_planes" {
  description = "Enable VKE HA control planes. Off by default for assignment cost; enable for a closer production control plane."
  type        = bool
  default     = false
}

variable "enable_firewall" {
  description = "Enable the VKE-managed firewall group."
  type        = bool
  default     = true
}

variable "node_quantity" {
  description = "Worker node count for the default node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.node_quantity >= 3
    error_message = "Use at least 3 workers so a single node failure does not take down the assignment cluster."
  }
}

variable "node_plan" {
  description = "Vultr instance plan for workers. vc2-2c-4gb is the assignment minimum; vc2-4c-8gb is safer once Istio, Prometheus, and databases are installed."
  type        = string
  default     = "vc2-4c-8gb"
}

variable "node_pool_label" {
  description = "Prefix for default node pool instances."
  type        = string
  default     = "cnp-worker"
}

variable "enable_node_autoscaler" {
  description = "Enable the VKE node pool autoscaler. Keep false unless you need extra workers."
  type        = bool
  default     = false
}

variable "autoscaler_min_nodes" {
  description = "Minimum nodes when autoscaler is enabled."
  type        = number
  default     = 3
}

variable "autoscaler_max_nodes" {
  description = "Maximum nodes when autoscaler is enabled."
  type        = number
  default     = 5
}

variable "registry_name" {
  description = "Private container registry name. Lowercase alphanumeric only. Must be unique on Vultr."
  type        = string
  default     = "cnpdemo"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.registry_name))
    error_message = "registry_name must be lowercase alphanumeric with no hyphens or underscores."
  }
}

variable "registry_plan" {
  description = "Vultr Container Registry plan slug (for example start_up)."
  type        = string
  default     = "start_up"
}

variable "project" {
  type    = string
  default = "cloud-native-platform"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "owner" {
  type    = string
  default = "devops-assignment"
}
