#! /bin/bash

dockerUserName="antoontuijl"

set -e
cd src

cd EventHubBackgroundWorker
docker build . -t $dockerUserName/aca-eventhub-background-worker:latest

cd ..
cd ServiceBusBackgroundWorker
docker build . -t $dockerUserName/aca-servicebus-background-worker:latest

cd ..
cd ..

docker push $dockerUserName/aca-eventhub-background-worker:latest
docker push $dockerUserName/aca-servicebus-background-worker:latest

echo "Docker Images were pushed to Docker Hub. Please remember providing your Docker Hub username also when deploying the infrastructure using Bicep (see deploy.sh)."
