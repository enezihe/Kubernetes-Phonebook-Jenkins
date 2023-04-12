output "rg_name" {
  value = azurerm_resource_group.rg3.name
}
output "aks_name" {
    value = azurerm_kubernetes_cluster.aks.name
}
output "noderg" {
    value = azurerm_kubernetes_cluster.aks.node_resource_group
  
}