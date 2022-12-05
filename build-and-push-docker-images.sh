#! /bin/bash

dockerUserName="antoontuijl"

set -e
cd src

docker build -t antoontuijl/aca-eventhub-background-worker:latest -f EventHubBackgroundWorker/Dockerfile .

docker build -t antoontuijl/aca-servicebus-background-worker:latest -f ServiceBusBackgroundWorker/Dockerfile .

cd ..
cd ..

docker push $dockerUserName/aca-eventhub-background-worker:latest
docker push $dockerUserName/aca-servicebus-background-worker:latest

echo "Docker Images were pushed to Docker Hub. Please remember providing your Docker Hub username also when deploying the infrastructure using Bicep (see deploy.sh)."
