terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.62.0"
    }
  }
}

variable "exoscale_api_key" {
  description = "Exoscale API key. Can also be set via the EXOSCALE_API_KEY environment variable."
  type        = string
  default     = null
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API secret. Can also be set via the EXOSCALE_API_SECRET environment variable."
  type        = string
  default     = null
  sensitive   = true
}

provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

variable "ssh_key_name" {
  description = "Name of an SSH key already registered in Exoscale"
  type        = string
}

module "k3s" {
  source = "../../"

  ssh_key_name = var.ssh_key_name
  cluster_name = "production-k3s"
  zone         = "de-fra-1"

  server_type = "standard.large"

  # Worker pool
  agent_count = 5
  agent_type  = "standard.extra-large"

  # Disk size
  disk_size = 100

  # Private network
  create_network       = true
  private_network_cidr = "10.50.1.0/24"

  # Restrict access to your office/VPN
  ssh_allowed_cidrs     = ["203.0.113.0/24"]
  k3s_api_allowed_cidrs = ["203.0.113.0/24"]

  flannel_backend = "wireguard-native"

  # Only install helm on servers, skip k9s and stern
  install_helm  = true
  install_k9s   = false
  install_stern = false

  extra_labels = {
    environment = "production"
    team        = "platform"
  }
}

output "server_ip" {
  value = module.k3s.server_public_ip
}

output "agent_ips" {
  value = module.k3s.agent_public_ips
}

output "kubeconfig_cmd" {
  value = module.k3s.kubeconfig_command
}
