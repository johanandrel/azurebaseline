

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.resource_group_tags
}

# Eksempel AD-gruppe som brukes til admin av DB-server
resource "azuread_group" "dbadmins" {
  display_name     = "eksempeladminadgruppe"
  members          = ["eksempel-object-id"]
  security_enabled = true
}

# Eksempel AD-gruppe som brukes til app-kommunikasjon mot database
resource "azuread_group" "dbappuser" {
  display_name     = "eksempelappadgruppe"
  members          = ["eksempel-object-id"]
  security_enabled = true
}

module "module1" {
  source                            = "./modules/sqlserver"
  resource_group_name               = azurerm_resource_group.resource_group.name
  location                          = azurerm_resource_group.resource_group.location
  sql_server_admin_identity_id      = azuread_group.dbadmins.object_id
  sql_server_admin_identity_name    = azuread_group.dbadmins.display_name
  sql_database_app_identity_id      = azuread_group.dbappuser.object_id
  sql_database_app_identity_name    = azuread_group.dbappuser.display_name
  sql_database_app_identity_isgroup = true
  tags                              = var.resource_group_tags
}