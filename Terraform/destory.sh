#!/bin/bash

cd ec2-kms-setup || { echo "Directory not found!"; exit 1; }

echo "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

echo "Terraform resources destroyed successfully."
