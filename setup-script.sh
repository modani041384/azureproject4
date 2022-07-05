#!/bin/bash

# Variables
resourceGroup="resource-group-west"
location="westus"
osType="UbuntuLTS"
vmssName="udacity-vmss"
adminName="udacityadmin"
storageAccount="udacitydiag2022"
bePoolName="vmss2022-bepool"
lbName="vmss2022-lb"
lbRule="vmss2022-lb-network-rule"
nsgName="udacity-vmss-nsg"
vnetName="udacity-vmss-vnet"
subnetName="udacity-vmss-subnet"
probeName="tcpProbe"
vmSize="Standard_B1s"
storageType="Standard_LRS"

# Create resource group. 
# This command will not work for the Cloud Lab users. 
# Cloud Lab users can comment this command and 
# use the existing Resource group name, such as, resourceGroup="cloud-demo-153430" 
echo "STEP 0 - Creating resource group resource-group-west..."

az group create \
--name resource-group-west \
--location eastus \
--verbose


az group create --name resource-group-west --location eastus --verbose



echo "Resource group created: resource-group-west"

# Create Storage account
echo "STEP 1 - Creating storage account udacitydiag2022"

az storage account create \
--name udacitydiag2022 \
--resource-group resource-group-west \
--location eastus \
--sku Standard_LRS


az storage account create --name udacitydiag2022 --resource-group resource-group-west --location eastus --sku Standard_LRS


echo "Storage account created: udacitydiag2022"

# Create Network Security Group
echo "STEP 2 - Creating network security group udacity-vmss-nsg"

az network nsg create \
--resource-group resource-group-west \
--name udacity-vmss-nsg \
--verbose


az network nsg create --resource-group resource-group-west --name udacity-vmss-nsg --verbose


echo "Network security group created: udacity-vmss-nsg"

# Create VM Scale Set
echo "STEP 3 - Creating VM scale set udacity-vmss"

az vmss create \
  --resource-group resource-group-west \
  --name udacity-vmss \
  --image UbuntuLTS \
  --vm-sku Standard_B1s \
  --nsg udacity-vmss-nsg \
  --subnet udacity-vmss-subnet \
  --vnet-name udacity-vmss-vnet \
  --backend-pool-name vmss2022-bepool \
  --storage-sku Standard_LRS \
  --load-balancer vmss2022-lb \
  --custom-data cloud-init.txt \
  --upgrade-policy-mode automatic \
  --admin-username udacityadmin \
  --generate-ssh-keys \
  --verbose 
  
  
  az vmss create --resource-group resource-group-west --name udacity-vmss --image UbuntuLTS --vm-sku Standard_B1s --nsg udacity-vmss-nsg --subnet udacity-vmss-subnet --vnet-name udacity-vmss-vnet --backend-pool-name vmss2022-bepool --storage-sku Standard_LRS --load-balancer vmss2022-lb --custom-data cloud-init.txt --upgrade-policy-mode automatic --admin-username udacityadmin --generate-ssh-keys --verbose 
  
  

echo "VM scale set created: udacity-vmss"

# Associate NSG with VMSS subnet
echo "STEP 4 - Associating NSG: udacity-vmss-nsg with subnet: $subnetName"

az network vnet subnet update \
--resource-group resource-group-west \
--name udacity-vmss-subnet \
--vnet-name udacity-vmss-vnet \
--network-security-group udacity-vmss-nsg \
--verbose


az network vnet subnet update --resource-group resource-group-west --name udacity-vmss-subnet --vnet-name udacity-vmss-vnet --network-security-group udacity-vmss-nsg --verbose


echo "NSG: udacity-vmss-nsg associated with subnet: $subnetName"

# Create Health Probe
echo "STEP 5 - Creating health probe tcpProbe"

az network lb probe create \
  --resource-group resource-group-west \
  --lb-name vmss2022-lb \
  --name tcpProbe \
  --protocol tcp \
  --port 80 \
  --interval 5 \
  --threshold 2 \
  --verbose


az network lb probe create --resource-group resource-group-west --lb-name vmss2022-lb --name tcpProbe --protocol tcp --port 80 --interval 5 --threshold 2 --verbose

echo "Health probe created: tcpProbe"

# Create Network Load Balancer Rule
echo "STEP 6 - Creating network load balancer rule $lbRule"

az network lb rule create \
  --resource-group resource-group-west \
  --name vmss2022-lb-network-rule \
  --lb-name vmss2022-lb \
  --probe-name tcpProbe \
  --backend-pool-name vmss2022-bepool \
  --backend-port 80 \
  --frontend-ip-name loadBalancerFrontEnd \
  --frontend-port 80 \
  --protocol tcp \
  --verbose


az network lb rule create --resource-group resource-group-west --name vmss2022-lb-network-rule --lb-name vmss2022-lb --probe-name tcpProbe --backend-pool-name vmss2022-bepool --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --verbose


echo "Network load balancer rule created: $lbRule"

# Add port 80 to inbound rule NSG
echo "STEP 7 - Adding port 80 to NSG udacity-vmss-nsg"

az network nsg rule create \
--resource-group resource-group-west \
--nsg-name udacity-vmss-nsg \
--name Port_80 \
--destination-port-ranges 80 \
--direction Inbound \
--priority 100 \
--verbose


az network nsg rule create --resource-group resource-group-west --nsg-name udacity-vmss-nsg --name Port_80 --destination-port-ranges 80 --direction Inbound --priority 100 --verbose


echo "Port 80 added to NSG: udacity-vmss-nsg"

# Add port 22 to inbound rule NSG
echo "STEP 8 - Adding port 22 to NSG udacity-vmss-nsg"

az network nsg rule create \
--resource-group resource-group-west \
--nsg-name udacity-vmss-nsg \
--name Port_22 \
--destination-port-ranges 22 \
--direction Inbound \
--priority 110 \
--verbose


az network nsg rule create --resource-group resource-group-west --nsg-name udacity-vmss-nsg --name Port_22 --destination-port-ranges 22 --direction Inbound --priority 110 --verbose

echo "Port 22 added to NSG: udacity-vmss-nsg"

echo "VMSS script completed!"
