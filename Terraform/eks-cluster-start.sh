#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

cd eks-cluster || { echo "Directory not found!"; exit 1; }

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan

echo "Applying Terraform changes..."
terraform apply -auto-approve 

echo "✅ Terraform resources are created"

aws eks update-kubeconfig --name practise-terraform-eks-demo --region us-east-1 --profile default

# Create namespace if not present
for ns in argocd logging; do
    if kubectl get ns "$ns" >/dev/null 2>&1; then
        echo "Namespace '$ns' already exists ✅"
    else
        echo "Creating namespace '$ns'..."
        kubectl create ns "$ns"
    fi
done

kubectl get ns

cd ../../argocd-helm

echo "Deploying Argo CD using Helm..."

# Install Argo CD only if not installed
if helm ls -n argocd | grep -q 'argocd'; then
    echo "Argo CD is already installed ✅"
else
    helm install argocd ./argo-cd -n argocd
fi

NAMESPACE="argocd"
TIMEOUT=300  # 5 minutes
INTERVAL=10  # check every 10 seconds
ELAPSED=0

echo "⏳ Waiting for Argo CD server pod to be in Running state..."

while [ $ELAPSED -lt $TIMEOUT ]; do
    POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].status.phase}" 2>/dev/null)

    if [ "$POD_STATUS" == "Running" ]; then
        echo "✅ Argo CD server pod is running."

        echo "---------------------------"
        echo "🔐 Argo CD Login Details:"
        echo "Username: admin"

        PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n $NAMESPACE -o jsonpath="{.data.password}" | base64 --decode)

        if [ -n "$PASSWORD" ]; then
            echo "Password: $PASSWORD"
        else
            echo "⚠️ Failed to fetch admin password."
        fi

        echo "---------------------------"
        break
    fi

    echo "⏳ Current pod status: $POD_STATUS, checking again in $INTERVAL seconds..."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ Argo CD server pod did not reach Running state within $((TIMEOUT/60)) minutes."
    echo "🔎 Fetching pod status and logs for debugging..."

    kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=argocd-server -o wide

    POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].metadata.name}")

    if [ -n "$POD_NAME" ]; then
        echo "🔧 Logs from pod: $POD_NAME"
        kubectl logs -n $NAMESPACE $POD_NAME
    else
        echo "⚠️ No argocd-server pod found."
    fi

    exit 1
fi

kubectl apply -f storageclass/storageclass-config.yaml
echo "✅ Storage class configured for EBS CSI driver"

echo "============================"
echo " Deploying AWS Cluster Autoscaler "
echo "============================"

kubectl apply -f applications/cluster-autoscaler.yaml
kubectl get pods -n kube-system | grep autoscaler

echo "Waiting for 1 minute before next deployment..."
sleep 60

echo "============================"
echo " Deploying Elasticsearch "
echo "============================"

kubectl apply -f applications/elasticsearch.yaml
kubectl get pods -n logging

echo "Waiting for 1 minute before next deployment..."
sleep 60
kubectl get pods -n logging

echo "============================"
echo " Deploying FileBeat "
echo "============================"

kubectl apply -f applications/filebeat.yaml
kubectl get pods -n logging

echo "Waiting for 1 minute before next deployment..."
sleep 60
kubectl get pods -n logging

echo "============================"
echo " Deploying Kibana "
echo "============================"

kubectl apply -f applications/kibana.yaml
kubectl get pods -n logging

echo "============================"
echo " All deployments completed successfully! "
echo "============================"
echo "Done ✅"
