locals {
  # When private network is enabled, agents join via private IP.
  # Otherwise, they join via the server's public IP.
  k3s_join_ip = var.create_network ? local.server_ips[0] : exoscale_compute_instance.server.public_ip_address
}

resource "exoscale_compute_instance" "agent" {
  count              = var.agent_count
  zone               = var.zone
  name               = "${var.cluster_name}-agent-${count.index + 1}"
  type               = var.agent_type
  template_id        = data.exoscale_template.os.id
  disk_size          = var.disk_size
  ssh_keys           = var.ssh_key_name != "" ? [var.ssh_key_name] : []
  security_group_ids = [exoscale_security_group.cluster.id]

  user_data = templatefile("${path.module}/templates/agent.yaml.tftpl", {
    k3s_token            = random_password.k3s_token.result
    k3s_version          = var.k3s_version
    k3s_join_url         = "https://${local.k3s_join_ip}:6443"
    k3s_agent_extra_args = var.k3s_agent_extra_args
    flannel_backend      = var.flannel_backend
    install_k9s          = var.install_k9s
    install_stern        = var.install_stern
  })

  dynamic "network_interface" {
    for_each = var.create_network ? [1] : []
    content {
      network_id = exoscale_private_network.cluster[0].id
      ip_address = local.agent_ips[count.index]
    }
  }

  labels = merge({
    cluster = var.cluster_name
    role    = "agent"
  }, var.extra_labels)

  # Agents must wait for the server to be ready
  depends_on = [exoscale_compute_instance.server]
}
