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

resource eventHubNamespace_ListenSend 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = {
  name: 'ListenSend'
  parent: eventHubNamespace
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
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

var eventHubNamespaceConnectionString = listKeys(eventHubNamespace_ListenSend.id, eventHubNamespace_ListenSend.apiVersion).primaryConnectionString

output eventHubNamespaceConnectionString string = eventHubNamespaceConnectionString
output eventHubName string = eventHubName
