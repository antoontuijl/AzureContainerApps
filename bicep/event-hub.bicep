param location string = resourceGroup().location
param eventHubNamespaceName string 
param eventHubNamespaceSku string = 'Basic'
param eventHubName string
param eventHubPartitionCount int = 1
param eventHubMessageRetentionInDays int = 1
param eventHubConsumerGroup string = '$Default'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubNamespaceSku
    tier: eventHubNamespaceSku
    capacity: 1
  }
  properties: {
    zoneRedundant: true
  }
}
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: eventHubMessageRetentionInDays
    partitionCount: eventHubPartitionCount
  }
}

resource eventHub_ListenSend 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-01-01-preview' = {
    parent: eventHub
    name: 'ListenSend'
    properties: {
      rights: [
        'Listen'
        'Send'
      ]
    }
    dependsOn: [
      eventHubNamespace
    ]
  }


/*resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: eventHub
  name: eventHubConsumerGroup
  properties: {
  }
  dependsOn: [
    eventHub
  ]
}*/

var eventHubNamespaceConnectionString = listKeys(eventHub_ListenSend.id, eventHub_ListenSend.apiVersion).primaryConnectionString

output eventHubNamespaceConnectionString string = eventHubNamespaceConnectionString
output eventHubNamespaceConnectionStringWithEntityPath string = '${eventHubNamespaceConnectionString};EntityPath=${eventHubName}'
output eventHubName string = eventHubName
