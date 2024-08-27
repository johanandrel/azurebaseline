data "azuread_client_config" "current" {}

resource "random_pet" "dbserver" {
  length    = 3
  separator = ""
}

resource "random_pet" "database" {
  length    = 3
  separator = ""
}

resource "azurerm_mssql_server" "dbserver" {
  name                = random_pet.dbserver.id
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"

  azuread_administrator {
    azuread_authentication_only = true
    object_id                   = var.sql_server_admin_identity_id
    login_username              = var.sql_server_admin_identity_name
  }
}

# For demo/POC bruk! Bruk Private Endpoints e.l. i tillegg for å lukke nettverk
resource "azurerm_mssql_firewall_rule" "dbserverfw" {
  name             = "localIP"
  server_id        = azurerm_mssql_server.dbserver.id
  start_ip_address = "skriv-inn-ip-hvis-POC"
  end_ip_address   = "skriv-inn-ip-hvis-POC"
}

resource "azurerm_mssql_database" "database" {
  name      = random_pet.database.id
  server_id = azurerm_mssql_server.dbserver.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S0"

  tags = var.tags
}

resource "terraform_data" "sqlserverusers" {
  
  triggers_replace = timestamp() # Trigges på hvert run i Terraform. Fjern hvis default lifecycle er ønskelig

  provisioner "local-exec" {
    command = ". '${path.module}/sqlserverusers.ps1'"
    environment = {
        serverName = azurerm_mssql_server.dbserver.fully_qualified_domain_name
        databaseName = azurerm_mssql_database.database.name
        identityId = var.sql_database_app_identity_id
        identityDisplayName = var.sql_database_app_identity_name
        identityIsGroup = var.sql_database_app_identity_isgroup
        databaseRoles = "db_datareader,db_datawriter"
    }

    interpreter = [
      "pwsh", "-Command"
    ]
  }
  depends_on = [azurerm_mssql_database.database]
}

