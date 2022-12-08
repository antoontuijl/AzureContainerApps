@description('Event Hub name')
param eventHubName string

@description('Event Hub consumer group name')
param eventHubConsumerGroupName string

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' existing = {
  name: eventHubName
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: eventHub
  name: eventHubConsumerGroupName
  properties: {
  }
}
