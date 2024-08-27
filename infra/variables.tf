variable "resource_group_name" {
  type        = string
  description = "Resource group name that is unique in your Azure subscription."
}

variable "resource_group_location" {
  type        = string
  default     = "Norway East"
  description = "Location of the resource group in your Azure subscription."
}

variable "resource_group_tags" {
  type        = map(string)
  description = "Tags to put metadata on the resource group in your Azure subscription."
  default = {
    Owner = "<email.address>"
  }
}