resource "exoscale_compute_instance" "server" {
  zone               = var.zone
  name               = "${var.cluster_name}-server"
  type               = var.server_type
  template_id        = data.exoscale_template.os.id
  disk_size          = var.disk_size
  ssh_keys           = var.ssh_key_name != "" ? [var.ssh_key_name] : []
  security_group_ids = [exoscale_security_group.cluster.id]

  user_data = templatefile("${path.module}/templates/server.yaml.tftpl", {
    k3s_token             = random_password.k3s_token.result
    k3s_version           = var.k3s_version
    k3s_server_extra_args = var.k3s_server_extra_args
    flannel_backend       = var.flannel_backend
    install_helm          = var.install_helm
    install_k9s           = var.install_k9s
    install_stern         = var.install_stern
  })

  dynamic "network_interface" {
    for_each = var.create_network ? [1] : []
    content {
      network_id = exoscale_private_network.cluster[0].id
      ip_address = local.server_ips[0]
    }
  }

  labels = merge({
    cluster = var.cluster_name
    role    = "server"
  }, var.extra_labels)

  depends_on = [exoscale_private_network.cluster]
}
