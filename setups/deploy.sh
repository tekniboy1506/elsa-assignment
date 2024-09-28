#!/bin/bash
source .env

export REGISTRY_URL=$REGISTRY_URL
export VERSION=$(git rev-parse --short HEAD)

kubectl apply -f k8s/config.yml
kubectl apply -f k8s/secret.yml
envsubst < k8s/deployment.yml | kubectl apply -f -