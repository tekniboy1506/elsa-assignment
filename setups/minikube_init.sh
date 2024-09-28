#!/bin/bash

docker network create --driver=bridge --subnet=192.168.49.0/24 minikube 
minikube start --network minikube 
minikube addons enable ingress

echo "Installing Local Docker Registry..."
docker run -d -p 5000:5000 --restart=always --name registry registry:2
echo REGISTRY_URL=192.168.49.1:5000 >> .env

echo "Installing MongoDB into Minikube..."
kubectl config set-context --current --namespace default
kubectl apply -f setups/mongodb
