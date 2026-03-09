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
  source       = "../../"
  ssh_key_name = var.ssh_key_name
  agent_count  = 3
}

output "server_ip" {
  value = module.k3s.server_public_ip
}

output "kubeconfig_cmd" {
  value = module.k3s.kubeconfig_command
}
