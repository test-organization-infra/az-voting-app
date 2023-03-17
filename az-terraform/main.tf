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
  name     = var.name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "infrarepo01" #this name cannot contain alphanumeric and can must unique
  resource_group_name = azurerm_resource_group.group-infra.name
  location            = azurerm_resource_group.group-infra.location
  sku                 = var.sku
}
resource "azurerm_kubernetes_cluster" "vote" {
  name                = "vote-aks"
  location            = azurerm_resource_group.group-infra.location
  resource_group_name = azurerm_resource_group.group-infra.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
  }

  identity {
    type = var.type
  }
}

resource "azurerm_role_assignment" "vote-role" {
  principal_id                     = azurerm_kubernetes_cluster.vote.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
