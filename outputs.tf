output "server_public_ip" {
  description = "Public IPv4 address of the server node"
  value       = exoscale_compute_instance.server.public_ip_address
}

output "server_private_ip" {
  description = "Private IP of the server node. Null when create_network is false."
  value       = var.create_network ? local.server_ips[0] : null
}

output "agent_public_ips" {
  description = "Map of agent node names to public IPv4 addresses"
  value       = { for s in exoscale_compute_instance.agent : s.name => s.public_ip_address }
}

output "agent_private_ips" {
  description = "Map of agent node names to private IPs"
  value       = var.create_network ? { for s in exoscale_compute_instance.agent : s.name => s.network_interface[0].ip_address } : {}
}

output "k3s_token" {
  description = "k3s cluster token"
  value       = random_password.k3s_token.result
  sensitive   = true
}

output "network_id" {
  description = "ID of the Exoscale private network. Null when create_network is false."
  value       = var.create_network ? exoscale_private_network.cluster[0].id : null
}

output "security_group_id" {
  description = "ID of the cluster security group"
  value       = exoscale_security_group.cluster.id
}

output "kubeconfig_command" {
  description = "Command to fetch kubeconfig from the server"
  value       = "ssh ubuntu@${exoscale_compute_instance.server.public_ip_address} sudo cat /etc/rancher/k3s/k3s.yaml | sed 's/127.0.0.1/${exoscale_compute_instance.server.public_ip_address}/g'"
}
