#! /bin/bash

dockerUserName="antoontuijl"

set -e
cd src

cd BackgroundWorker
docker build . -t $dockerUserName/aca-background-worker:latest

cd ..
cd ..

docker push $dockerUserName/aca-background-worker:latest

echo "Docker Images were pushed to Docker Hub. Please remember providing your Docker Hub username also when deploying the infrastructure using Bicep (see deploy.sh)."
