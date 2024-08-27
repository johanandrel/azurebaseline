variable "resource_group_name" {
  type        = string
  description = "Resource group name that is unique in your Azure subscription."
}

variable "location" {
  type        = string
  default     = "Norway East"
  description = "Location in your Azure subscription."
}

variable "sql_server_admin_identity_id" {
  type = string
  description = "The object ID of the group or user that will administer the SQL-Server"
}

variable "sql_server_admin_identity_name" {
  type = string
  description = "The username/display_name of the group or user that will administer the SQL-Server"
}

variable "sql_database_app_identity_id" {
  type = string
  description = "The object ID of the group or user that will connect to the SQL-database"
}

variable "sql_database_app_identity_name" {
  type = string
  description = "The username/display_name of the group or user that will connect to the SQL-database"
}

variable "sql_database_app_identity_isgroup" {
  type = bool
  description = "Is the identity a group?"
}

variable "tags" {
  type        = map(string)
  description = "Tags to put metadata on the resource."
}
