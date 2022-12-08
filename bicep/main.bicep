param location string = resourceGroup().location
param name string = 'background-worker'
param storageAccountName string = 'saacabackgroundworker'
param dockerUserName string = 'antoontuijl'

param eventHubWorkerRepository string = 'aca-eventhub-background-worker'
param serviceBusWorkerRepository string = 'aca-servicebus-background-worker'
param workerTag string = 'latest'

var queueName = 'work'
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

module serviceBus 'service-bus.bicep' = {
    name: 'service-bus'
    params: {
        name: 'thns${name}'
        location: location
        queueName: queueName
    }
}


module eventHubNamespace 'event-hub-namespace.bicep' = {
    name: 'event-hub-namespace'
    params: {
        location: location
        eventHubNamespaceName: 'backgroundworker-eh'
    }
}

module eventHub 'event-hub.bicep' = {
    name: 'event-hub'
    params: {
        eventHubNamespaceName: 'backgroundworker-eh'
        eventHubName: eventHubName
    }
    dependsOn: [
        eventHubNamespace
    ]
}

module eventhub_worker 'aca.bicep' = {
    name: 'app-eventhub-worker'
    params: {
        location: location
        name: 'eventhub-worker'
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: '${dockerUserName}/${eventHubWorkerRepository}:${workerTag}'
        secrets: [
            {
                name: 'storage-account-connection-string'
                value: storageAccount.outputs.StorageAccountConnectionString
            }
            {
                name: 'event-hub-connection-string'
                value: eventHub.outputs.eventHubConnectionString
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

module servicebus_worker 'aca.bicep' = {
    name: 'app-servicebus-worker'
    params: {
        location: location
        name: 'servicebus-worker'
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: '${dockerUserName}/${serviceBusWorkerRepository}:${workerTag}'
        secrets: [
            {
                name: 'storage-account-connection-string'
                value: storageAccount.outputs.StorageAccountConnectionString
            }
            {
                name: 'service-bus-connection-string'
                value: serviceBus.outputs.ServiceBusConnectionString
            }
        ]
        envVars: [
            {
                name: 'QueueConfig__QueueName'
                value: queueName
            }
            {
                name: 'QueueConfig__ConnectionString'
                secretRef: 'service-bus-connection-string'
            }
            {
                name: 'BlobConfig__ContainerName'
                value: resultsContainerName
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
                name: 'queue-trigger'
                custom: {
                    type: 'azure-servicebus'
                    metadata: {
                        queueName: queueName
                        messageCount: '5'
                    }
                    auth: [{
                        secretRef: 'service-bus-connection-string'
                        triggerParameter: 'connection'
                    }]
                }
            }
        ]
    }
}
