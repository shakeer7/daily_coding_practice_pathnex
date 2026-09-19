# ==========================================
# Consolidated Shakeer Azure Terraform
# ==========================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Modern AzureRM 4.x provider as of 2026
    }
  }
}

provider "azurerm" {
  features {}
}

# ==========================================
# Resource Group
# ==========================================
resource "azurerm_resource_group" "ShakeerRG" {
  name     = "Shakeer-RG"
  location = "East US"
}

# ==========================================
# 1. Network Resources
# ==========================================
resource "azurerm_virtual_network" "ShakeerVNet" {
  name                = "Shakeer-VNet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  tags                = { Name = "Shakeer-VNet" }
}

resource "azurerm_subnet" "ShakeerSubnet" {
  name                 = "Shakeer-Subnet"
  resource_group_name  = azurerm_resource_group.ShakeerRG.name
  virtual_network_name = azurerm_virtual_network.ShakeerVNet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_route_table" "ShakeerRT" {
  name                = "Shakeer-RouteTable"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name

  route {
    name           = "InternetOutbound"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
  tags = { Name = "Shakeer-RouteTable" }
}

resource "azurerm_subnet_route_table_association" "ShakeerRTA" {
  subnet_id      = azurerm_subnet.ShakeerSubnet.id
  route_table_id = azurerm_route_table.ShakeerRT.id
}

# ==========================================
# 2. Security
# ==========================================
resource "azurerm_network_security_group" "ShakeerNSG" {
  name                = "Shakeer-NSG"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = { Name = "Shakeer-NSG" }
}

resource "azurerm_subnet_network_security_group_association" "ShakeerNSGAttach" {
  subnet_id                 = azurerm_subnet.ShakeerSubnet.id
  network_security_group_id = azurerm_network_security_group.ShakeerNSG.id
}

# ==========================================
# 3. Compute
# ==========================================
resource "azurerm_public_ip" "ShakeerPIP" {
  name                = "Shakeer-PublicIP"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  allocation_method   = "Static"
  tags                = { Name = "Shakeer-PIP" }
}

resource "azurerm_network_interface" "ShakeerNIC" {
  name                = "Shakeer-NIC"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ShakeerSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ShakeerPIP.id
  }
}

resource "azurerm_linux_virtual_machine" "ShakeerVM" {
  name                = "Shakeer-VM"
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  location            = azurerm_resource_group.ShakeerRG.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.ShakeerNIC.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Name        = "Shakeer-VM"
    Environment = "Training"
    Owner       = "ShakeerStudent"
  }
}

# ==========================================
# 4. Storage
# ==========================================
resource "azurerm_managed_disk" "ShakeerDataDisk" {
  name                 = "Shakeer-DataDisk"
  location             = azurerm_resource_group.ShakeerRG.location
  resource_group_name  = azurerm_resource_group.ShakeerRG.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 20
  tags                 = { Name = "Shakeer-DataDisk" }
}

resource "azurerm_virtual_machine_data_disk_attachment" "ShakeerDiskAttach" {
  managed_disk_id    = azurerm_managed_disk.ShakeerDataDisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.ShakeerVM.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_storage_account" "ShakeerStorage" {
  name                     = "shakeerdevopsstorage"
  resource_group_name      = azurerm_resource_group.ShakeerRG.name
  location                 = azurerm_resource_group.ShakeerRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = { Name = "ShakeerStorageAccount" }
}

resource "azurerm_storage_container" "ShakeerContainer" {
  name                  = "shakeer-devops-container"
  storage_account_name  = azurerm_storage_account.ShakeerStorage.name
  container_access_type = "private"
}

# ==========================================
# 5. Database (Modernized to Flexible Server)
# ==========================================
resource "azurerm_mysql_flexible_server" "ShakeerMySQL" {
  name                   = "shakeerdb-server"
  resource_group_name    = azurerm_resource_group.ShakeerRG.name
  location               = azurerm_resource_group.ShakeerRG.location
  administrator_login    = "adminuser"
  administrator_password = "Shakeer123Password!"

  # Standard sizing for MySQL Flexible Server
  sku_name              = "B_Standard_B1ms"
  version               = "8.0.21"
  zone                  = "1"
  backup_retention_days = 7
}

resource "azurerm_cosmosdb_account" "ShakeerCosmos" {
  name                = "shakeertrainingtable"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.ShakeerRG.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_table" "ShakeerTable" {
  name                = "ShakeerTrainingTable"
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  account_name        = azurerm_cosmosdb_account.ShakeerCosmos.name
  throughput          = 400
}

# ==========================================
# 6. Load Balancing
# ==========================================
resource "azurerm_public_ip" "ShakeerALBPIP" {
  name                = "shakeer-alb-pip"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "ShakeerALB" {
  name                = "shakeer-alb"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ShakeerALBPIP.id
  }
}

# ==========================================
# 7. Containers (AKS & ACR) - Added Aug 2026
# ==========================================
resource "azurerm_container_registry" "ShakeerACR" {
  name                = "shakeeracrregistry"
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  location            = azurerm_resource_group.ShakeerRG.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = { Name = "Shakeer-ACR" }
}

resource "azurerm_kubernetes_cluster" "ShakeerAKS" {
  name                = "Shakeer-AKS"
  location            = azurerm_resource_group.ShakeerRG.location
  resource_group_name = azurerm_resource_group.ShakeerRG.name
  dns_prefix          = "shakeer-aks"
  kubernetes_version  = "1.30" # Standard modern version for Aug 2026

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.ShakeerSubnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = { Name = "Shakeer-AKS" }
}

# Role assignment allowing AKS to pull images from ACR
resource "azurerm_role_assignment" "ShakeerAKSACRPull" {
  principal_id                     = azurerm_kubernetes_cluster.ShakeerAKS.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.ShakeerACR.id
  skip_service_principal_aad_check = true
}

# ==========================================
# 8. Outputs
# ==========================================
output "ShakeerPublicIP" {
  value = azurerm_public_ip.ShakeerPIP.ip_address
}

output "ShakeerAKSClusterName" {
  value = azurerm_kubernetes_cluster.ShakeerAKS.name
}

output "ShakeerACRLoginServer" {
  value = azurerm_container_registry.ShakeerACR.login_server
}
