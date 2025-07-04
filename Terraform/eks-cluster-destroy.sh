#!/bin/bash

cd eks-cluster || { echo "Directory not found!"; exit 1; }

echo "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

echo "Terraform resources destroyed successfully."
