@description('Event Hub namespace where the event hub will be created')
param eventHubNamespaceName string 

@description('Event Hub name')
param eventHubName string

@description('The number of partitions in the event hub')
param eventHubPartitionCount int = 1

@description('Message rentention days (1 for Basic tier)')
param eventHubMessageRetentionInDays int = 1

@description('Authorization Rule name for Send and Listen')
param authorizationRuleName string = 'ListenSend'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespaceName
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: eventHubMessageRetentionInDays
    partitionCount: eventHubPartitionCount
  }
}

resource eventHub_ListenSend 'Microsoft.EventHub/namespaces/eventHubs/authorizationRules@2021-11-01' = {
  name: authorizationRuleName
  parent: eventHub
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

var eventHubConnectionString = listKeys(eventHub_ListenSend.id, eventHub_ListenSend.apiVersion).primaryConnectionString

output eventHubConnectionString string = eventHubConnectionString
output eventHubName string = eventHubName
