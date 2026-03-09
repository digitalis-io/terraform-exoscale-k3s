# ── Required ─────────────────────────────────────────────
variable "ssh_key_name" {
  description = "Name of an SSH key already registered in Exoscale"
  type        = string
  default     = ""
}

# ── Cluster identity ─────────────────────────────────────
variable "cluster_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "digitalis-k3s"
}

# ── Server (control-plane) ─────────────────────────────────
variable "server_type" {
  description = "Exoscale instance type for control-plane nodes (e.g. standard.medium, standard.large)"
  type        = string
  default     = "standard.medium"
}

# ── Agent (worker) pool ──────────────────────────────────
variable "agent_count" {
  description = "Number of k3s agent (worker) nodes"
  type        = number
  default     = 2
}

variable "agent_type" {
  description = "Exoscale instance type for agent/worker nodes (e.g. standard.medium, standard.large)"
  type        = string
  default     = "standard.medium"
}

# ── Zone & template ─────────────────────────────────────
variable "zone" {
  description = "Exoscale zone (e.g. ch-gva-2, de-fra-1, de-muc-1, at-vie-1, at-vie-2, bg-sof-1)"
  type        = string
  default     = "ch-gva-2"
}

variable "template" {
  description = "OS template name for all nodes"
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

variable "disk_size" {
  description = "Disk size in GB for all nodes"
  type        = number
  default     = 50
}

# ── Networking ───────────────────────────────────────────
variable "create_network" {
  description = "Create a private network for inter-node communication. When false, nodes communicate over public IPs."
  type        = bool
  default     = false
}

variable "private_network_cidr" {
  description = "CIDR for the Exoscale private network"
  type        = string
  default     = "10.13.1.0/24"
}

# ── Security group (firewall) ─────────────────────────────
variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH into nodes"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "k3s_api_allowed_cidrs" {
  description = "CIDRs allowed to reach the k3s API (port 6443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nodeport_allowed_cidrs" {
  description = "CIDRs allowed to reach NodePort services (30000-32767). Set to empty list to disable."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "extra_security_group_rules" {
  description = "Additional security group rules to apply to all nodes"
  type = list(object({
    protocol               = string
    type                   = optional(string, "INGRESS")
    start_port             = number
    end_port               = number
    cidr                   = optional(string)
    user_security_group_id = optional(string)
    description            = optional(string)
  }))
  default = []
}

# ── k3s options ──────────────────────────────────────────
variable "k3s_version" {
  description = "k3s version to install (e.g. v1.31.4+k3s1). Empty string installs the stable channel."
  type        = string
  default     = ""
}

variable "k3s_server_extra_args" {
  description = "Extra arguments passed to the k3s server install"
  type        = string
  default     = ""
}

variable "k3s_agent_extra_args" {
  description = "Extra arguments passed to the k3s agent install"
  type        = string
  default     = ""
}

variable "flannel_backend" {
  description = "Flannel backend (wireguard-native, vxlan, host-gw, etc.)"
  type        = string
  default     = "wireguard-native"
}

# ── Optional tool installation ───────────────────────────
variable "install_helm" {
  description = "Install Helm 3 on server nodes"
  type        = bool
  default     = true
}

variable "install_k9s" {
  description = "Install k9s on all nodes"
  type        = bool
  default     = true
}

variable "install_stern" {
  description = "Install Stern on all nodes"
  type        = bool
  default     = true
}

# ── Extra labels ─────────────────────────────────────────
variable "extra_labels" {
  description = "Additional labels to apply to all resources"
  type        = map(string)
  default     = {}
}
