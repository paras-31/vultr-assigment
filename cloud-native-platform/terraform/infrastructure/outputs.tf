output "cluster_id" {
  description = "VKE cluster UUID."
  value       = vultr_kubernetes.cluster.id
}

output "cluster_label" {
  description = "VKE cluster label."
  value       = vultr_kubernetes.cluster.label
}

output "cluster_region" {
  description = "Region of the VKE cluster."
  value       = vultr_kubernetes.cluster.region
}

output "kubernetes_version" {
  description = "Kubernetes version actually provisioned by VKE."
  value       = vultr_kubernetes.cluster.version
}

output "cluster_status" {
  description = "Current VKE cluster status."
  value       = vultr_kubernetes.cluster.status
}

output "cluster_endpoint" {
  description = "Kubernetes API server hostname."
  value       = vultr_kubernetes.cluster.endpoint
}

output "cluster_ip" {
  description = "Kubernetes API server IP."
  value       = vultr_kubernetes.cluster.ip
}

output "ha_control_planes" {
  description = "Whether HA control planes were requested."
  value       = vultr_kubernetes.cluster.ha_controlplanes
}

output "firewall_group_id" {
  description = "Firewall group managed by VKE when enable_firewall is true."
  value       = vultr_kubernetes.cluster.firewall_group_id
}

output "node_pool_id" {
  description = "Default node pool ID."
  value       = vultr_kubernetes.cluster.node_pools[0].id
}

output "node_quantity" {
  description = "Configured worker count."
  value       = vultr_kubernetes.cluster.node_pools[0].node_quantity
}

output "kube_config" {
  description = "Base64-encoded kubeconfig. Decode locally; never commit the file."
  value       = vultr_kubernetes.cluster.kube_config
  sensitive   = true
}

output "registry_id" {
  description = "Vultr Container Registry ID."
  value       = vultr_container_registry.app.id
}

output "registry_name" {
  description = "Container registry name."
  value       = vultr_container_registry.app.name
}

output "registry_region" {
  description = "Container registry region."
  value       = vultr_container_registry.app.region
}

output "registry_urn" {
  description = "Container registry URN."
  value       = vultr_container_registry.app.urn
}

output "registry_public" {
  description = "Whether the registry is public. Must remain false for this assignment."
  value       = vultr_container_registry.app.public
}

output "registry_username" {
  description = "Registry root username. Store in GitHub secret VCR_USERNAME later."
  value       = vultr_container_registry.app.root_user[0].username
  sensitive   = true
}

output "registry_password" {
  description = "Registry root password. Store in GitHub secret VCR_PASSWORD later."
  value       = vultr_container_registry.app.root_user[0].password
  sensitive   = true
}

output "common_labels" {
  description = "Standard labels applied to worker nodes."
  value       = local.common_labels
}
