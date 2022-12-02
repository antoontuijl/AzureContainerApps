param location string = resourceGroup().location
param name string = 'background-worker'
param storageAccountName string = 'saacabackgroundworker'
param dockerUserName string = 'antoontuijl'

param workerRepository string = 'aca-background-worker'
param workerTag string = 'latest'

var eventHubName = 'interactions'
var resultsContainerName = 'results'
var eventHubContainerName = 'events'
var eventHubConsumerGroup = '$Default'

module containerAppEnvironment 'environment.bicep' = {
    name: 'container-app-environment'
    params: {
        name: 'env-${name}'
        location: location
    }
}

module storageAccount 'storage-account.bicep' = {
    name: 'storage-account'
    params: {
        name: storageAccountName
        location: location
        resultsContainerName: resultsContainerName
        eventhubContainerName: eventHubContainerName
    }
}

module eventHub 'event-hub.bicep' = {
    name: 'event-hub'
    params: {
        location: location
        eventHubNamespaceName: 'backgroundworker-eh'
        eventHubName: eventHubName
        eventHubConsumerGroup: eventHubConsumerGroup
    }
}

module app_worker 'aca.bicep' = {
    name: 'app-worker'
    params: {
        location: location
        name: 'worker'
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: '${dockerUserName}/${workerRepository}:${workerTag}'
        secrets: [
            {
                name: 'storage-account-connection-string'
                value: storageAccount.outputs.StorageAccountConnectionString
            }
            {
                name: 'event-hub-connection-string'
                value: eventHub.outputs.eventHubNamespaceConnectionString
            }
        ]
        envVars: [
            {
                name: 'EventHubConfig__EventHubName'
                value: eventHubName
            }
            {
                name: 'EventHubConfig__ConnectionString'
                secretRef: 'event-hub-connection-string'
            }
            {
                name: 'BlobConfig__ContainerName'
                value: resultsContainerName
            }
            {
                name: 'BlobConfig__EventHubContainerName'
                value: eventHubContainerName
            }
            {
                name: 'BlobConfig__ConnectionString'
                secretRef: 'storage-account-connection-string'
            }
        ]
        useExternalIngress: false
        
        minReplicas: 0
        maxReplicas: 10
        scaleRules: [
            {
                name: 'eventhub-trigger'
                custom: {
                    type: 'azure-eventhub'
                    metadata: {
                      eventHubName: eventHubName
                      consumerGroup: eventHubConsumerGroup
                    }
                    auth: [
                      {
                        secretRef: 'event-hub-connection-string'
                        triggerParameter: 'connection'
                      }
                      {
                        secretRef: 'storage-account-connection-string'
                        triggerParameter: 'storageConnection'
                      }
                    ]
                }
            }
        ]
    }
}
