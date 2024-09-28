#!/bin/bash
echo "Installing Local Docker Registry..."
docker run -d -p 5000:5000 --restart=always --name registry registry:2

minikube start --insecure-registry="192.168.49.1:5000"
minikube addons enable ingress

echo "Installing MongoDB into Minikube..."
kubectl config set-context --current --namespace default
kubectl apply -f setups/mongodb

echo REGISTRY_URL=192.168.49.1:5000 >> .env