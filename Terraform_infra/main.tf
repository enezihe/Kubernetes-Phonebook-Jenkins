terraform {
  backend "azurerm" {
    resource_group_name  = "nbt-rg-test"
    storage_account_name = "nbtteststorage"
    container_name       = "k8sjenkins"
    key                  = "terraform.tfstate"
    use_msi = true
     subscription_id = "fe0a3c7c-f676-4acb-91ac-89f5008cbba1"
     tenant_id = "1a93b615-8d62-418a-ac28-22501cf1f978"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"

    }

  }
}
# Configure the GitHub Provider
provider "github" {}

provider "azurerm" {
  # Configuration options
  features {

  }
  use_msi = true
     subscription_id = "fe0a3c7c-f676-4acb-91ac-89f5008cbba1"
     tenant_id = "1a93b615-8d62-418a-ac28-22501cf1f978"
}

resource "azurerm_resource_group" "rg3" {
  name     = var.name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg3.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
data "azurerm_lb" "lb" {
  name                = "kubernetes"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group #node.rg'nin ismini veriyor
}
resource "azurerm_lb_rule" "rule1" {
  loadbalancer_id                = data.azurerm_lb.lb.id
  name                           = "rule1"
  protocol                       = "Tcp"
  frontend_port                  = 30001
  backend_port                   = 30001
  frontend_ip_configuration_name = data.azurerm_lb.lb.frontend_ip_configuration.0.name
  disable_outbound_snat = true
  probe_id = azurerm_lb_probe.probe3001.id
  backend_address_pool_ids = [data.azurerm_lb_backend_address_pool.backAP.id]
}
resource "azurerm_lb_rule" "rule2" {
  loadbalancer_id                = data.azurerm_lb.lb.id
  name                           = "rule2"
  protocol                       = "Tcp"
  frontend_port                  = 30002
  backend_port                   = 30002
  frontend_ip_configuration_name = data.azurerm_lb.lb.frontend_ip_configuration.0.name
  disable_outbound_snat = true 
  probe_id = azurerm_lb_probe.probe3002.id
  backend_address_pool_ids = [data.azurerm_lb_backend_address_pool.backAP.id]
  }

  data "azurerm_lb_backend_address_pool" "backAP" {
  name            = "kubernetes"
  loadbalancer_id = data.azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe3001" {
  loadbalancer_id = data.azurerm_lb.lb.id
  name            = "probe_30001"
  port            = 30001
}

resource "azurerm_lb_probe" "probe3002" {
  loadbalancer_id = data.azurerm_lb.lb.id
  name            = "probe_30002"
  port            = 30002
}



