terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group-infra" {
  name     = "example"
  location = "eastus"
}

resource "azurerm_container_registry" "acr" {
  name                = "infrarepo01"
  resource_group_name = azurerm_resource_group.group-infra.name
  location            = azurerm_resource_group.group-infra.location
  sku                 = "Basic"
  #admin_enabled       = false
}
resource "azurerm_kubernetes_cluster" "vote" {
  name                = "vote-aks"
  location            = azurerm_resource_group.group-infra.location
  resource_group_name = azurerm_resource_group.group-infra.name
  dns_prefix          = "vote-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "vote-role" {
  principal_id                     = azurerm_kubernetes_cluster.vote.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}