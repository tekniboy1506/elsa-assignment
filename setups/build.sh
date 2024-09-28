#!/bin/bash

source .env
VERSION=$(git rev-parse --short HEAD)

docker build -t $REGISTRY_URL/elsa:$VERSION .
docker push $REGISTRY_URL/elsa:$VERSION

