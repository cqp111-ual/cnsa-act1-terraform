variable "azure-subscription" {
  description = "Azure subscription id"
}

variable "azure-tenant" {
  description = "Azure tenant id"
}

variable "azure-resource-group" {
  description = "Azure resource group name"
}

variable "azure-location" {
  description = "Azure location"
}

variable "azure-net-name" {
  description = "Azure virtual net name"
}

variable "azure-address-space" {
  description = "Azure address space"
  type        = list(string)
}

variable "azure-dns-servers" {
  description = "Azure DNS servers"
  type        = list(string)
}

variable "azure-subnet-name" {
  description = "Azure subnet name"
}

variable "azure-subnet-prefixes" {
  description = "Azure subnet prefixes"
  type        = list(string)
}

# Global VM options

variable "azure-vm-size" {
  description = "Azure VM size"
}

variable "azure-admin-username" {
  description = "Admin username"
}

variable "azure-storage-account-type" {
  description = "Storage account type"
  default     = "Standard_LRS"
}

variable "azure-os-publisher" {
  description = "Publisher of the image"
  default     = "Canonical"
}

variable "azure-os-offer" {
  description = "Offer of the image"
  default     = "0001-com-ubuntu-server-noble"
}

variable "azure-os-sku" {
  description = "SKU of the image"
  default     = "24_04-lts"
}

variable "azure-os-version" {
  description = "Version of the image"
  default     = "latest"
}

# Jenkins VM specific options

variable "jenkins-privateip-address" {
  description = "Jenkins VM private IP address"
}

variable "jenkins-vm-name" {
  description = "Jenkins VM name"
}

# Deployment node VM specific options

variable "deploy-privateip-address" {
  description = "Deployment node VM private IP address"
}

variable "deploy-vm-name" {
  description = "Deployment node VM name"
}