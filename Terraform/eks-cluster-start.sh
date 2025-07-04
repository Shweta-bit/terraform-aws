#!/bin/bash
cd eks-cluster || { echo "Directory not found!"; exit 1; }

# Set default profile name
# PROFILE_NAME="default"

# Terraform init
echo "Initializing Terraform..."
terraform init

# Terraform plan using the profile variable
echo "Planning Terraform changes..."
terraform plan

# Terraform apply without prompt
echo "Applying Terraform changes..."
terraform apply -auto-approve 

echo "Done ✅"
