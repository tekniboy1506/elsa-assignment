#!/bin/bash
minikube start
minikube addons enable ingress
kubectl create namespace docker-repo

echo "Installing Local Docker Registry..."
kubectl config set-context --current --namespace docker-repo
kubectl apply -f setups/docker-registry/docker-registry.yml
kubectl wait --for=condition=Ready pod/local-registry
echo REGISTRY_URL=$(minikube ip):=$(kubectl get svc local-registry-service -o jsonpath='{.spec.ports[0].nodePort}') >> .env

echo "Installing MongoDB into Minikube..."
kubectl config set-context --current --namespace default
kubectl apply -f setups/mongodb
