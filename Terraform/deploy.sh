#!/bin/bash

cd ec2-kms-setup || { echo "Directory not found!"; exit 1; }

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Applying Terraform deployment..."
terraform apply -auto-approve

# Capture the public IP from Terraform output
public_ip=$(terraform output -raw public_ip)

echo "Application can be accessed at http://$public_ip:8081/api/v1"

cd ../../..


echo "Current directory at start: $(pwd)"

echo "[monitoring]" > ./ansible_proj/node_exporter-setup/inventory/hosts.ini
echo "ec2-instance ansible_host=$public_ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem" >> ./ansible_proj/node_exporter-setup/inventory/hosts.ini

# Move to base dir and run Ansible
cd ./ansible_proj/node_exporter-setup || { echo "Directory not found!"; exit 1; }
echo "Running Ansible Playbook to install Prometheus and Node Exporter..."
ansible-playbook install_monitoring_stack.yml

echo "Checking if Node Exporter is running on port 9100..."
curl -sSf http://$public_ip:9100/metrics > /dev/null \
  && echo "✅ Node Exporter is running!" \
  || echo "❌ Node Exporter is NOT running!"

echo "Checking if Prometheus is running on port 9090..."
curl -sSf http://$public_ip:9090/graph > /dev/null \
  && echo "✅ Prometheus is running!" \
  || echo "❌ Prometheus is NOT running!"
