provider "proxmox" {
  endpoint  = "https://192.168.1.70:8006/"
  api_token = "terraform@pam!ares-automation=${var.proxmox_api_token_secret}"

  insecure = true
}
