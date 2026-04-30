variable "subscription_id" {
  description = "Azure subscription ID used by Terraform."
  type        = string
}

variable "project_name" {
  description = "Project prefix for Azure resources."
  type        = string
  default     = "cloudeco-a1"
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "rg-cloudeco-a1"
}

variable "admin_username" {
  description = "Admin username for the Linux VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for VM login."
  type        = string
  default     = "../keys/cloudeco_a1_key.pub"
}

variable "admin_source_cidr" {
  description = "Public source IP range allowed to access SSH, Kubernetes API, and NodePort services."
  type        = string
  default     = "*"
}

variable "nodes" {
  description = "Multi-region Kubernetes VM nodes."
  type = map(object({
    location      = string
    vm_size       = string
    address_space = string
    subnet_prefix = string
    role          = string
  }))

  default = {
    cloudeco-master = {
      location      = "indonesiacentral"
      vm_size       = "Standard_F4als_v6"
      address_space = "10.10.0.0/16"
      subnet_prefix = "10.10.1.0/24"
      role          = "master"
    }

    cloudeco-worker-1 = {
      location      = "malaysiawest"
      vm_size       = "Standard_F4als_v6"
      address_space = "10.20.0.0/16"
      subnet_prefix = "10.20.1.0/24"
      role          = "worker"
    }

    cloudeco-worker-2 = {
      location      = "japaneast"
      vm_size       = "Standard_D4s_v3"
      address_space = "10.30.0.0/16"
      subnet_prefix = "10.30.1.0/24"
      role          = "worker"
    }
  }
}

variable "tags" {
  description = "Common tags for Azure resources."
  type        = map(string)
  default = {
    project = "FIT5225-A1-CloudEco"
    owner   = "student"
    managed = "terraform"
  }
}