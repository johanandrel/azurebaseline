resource "random_pet" "storageaccount" {
  length    = 2
  separator = ""
}

resource "random_pet" "storagecontainer" {
  length    = 2
  separator = ""
}

# For demo/POC bruk slik at man kan teste authentisering og autorisering! 
# Bruk Private Endpoints e.l. for å lukke nettverk i tillegg til public_network_access_enabled = false
resource "azurerm_storage_account" "storage" {
  name                            = random_pet.storageaccount.id
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard" # Standard for POC/testing, Premium for ytterligere kapabiliteter på kryptering etc.
  account_replication_type        = "GRS"
  shared_access_key_enabled       = false
  local_user_enabled              = false
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true 
}

resource "azurerm_storage_container" "container" {
  name                  = random_pet.storagecontainer.id
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# RBAC bør scopes til container ikke på en hel Storage Account
resource "azurerm_role_assignment" "containercontributor" {
  scope                = azurerm_storage_container.container.resource_manager_id
  principal_id         = "ada7c36d-b269-43f5-a36b-e251114c21d6"
  role_definition_name = "Storage Blob Data Contributor"
}
