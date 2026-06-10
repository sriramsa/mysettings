variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create/use (e.g. mydev-rg)."
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "westus2"
}

variable "vm_name" {
  type        = string
  description = "VM name; also used to name the VNET/Subnet/NSG/IP/NIC."
}

variable "vm_size" {
  type        = string
  description = "VM size."
  default     = "Standard_B4ms"
}

variable "admin_username" {
  type        = string
  description = "Linux admin username (the account the env is set up for)."
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH PUBLIC key on the machine running terraform (e.g. ~/.ssh/id_ed25519.pub)."
}

variable "dns_label" {
  type        = string
  description = "DNS label -> <label>.<region>.cloudapp.azure.com (your stable SSH host)."
}

variable "ssh_source_address" {
  type        = string
  description = "Allowed SSH source. '*' = anywhere (matches live box); set to your IP/CIDR to lock down."
  default     = "*"
}

variable "os_disk_type" {
  type        = string
  description = "OS disk storage type."
  default     = "StandardSSD_LRS"
}

variable "repo_url" {
  type        = string
  description = "Git URL of this dotfiles repo (cloud-init clones it to bootstrap the OS)."
}

variable "autoshutdown_time" {
  type        = string
  description = "Daily auto-shutdown time, 24h HHMM."
  default     = "2300"
}

variable "autoshutdown_timezone" {
  type        = string
  description = "Auto-shutdown timezone (Windows tz name)."
  default     = "Pacific Standard Time"
}

variable "autoshutdown_warn_minutes" {
  type        = number
  description = "Minutes before shutdown to send the email warning."
  default     = 30
}

variable "autoshutdown_email" {
  type        = string
  description = "Email for the auto-shutdown warning."
}

variable "monthly_budget" {
  type        = number
  description = "Monthly cost budget (USD) that triggers alerts."
  default     = 150
}

variable "budget_alert_email" {
  type        = string
  description = "Email for budget alerts; blank uses autoshutdown_email."
  default     = ""
}

variable "budget_start_date" {
  type        = string
  description = "Budget start (RFC3339); must be the first of a month, on/before today."
  default     = "2026-06-01T00:00:00Z"
}
