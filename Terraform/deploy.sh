#!/bin/bash

cd ec2-kms-setup || { echo "Directory not found!"; exit 1; }

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Applying Terraform deployment..."
terraform apply -auto-approve

echo "Application can be accessed at http://<public-ip>:8081/api/v1"