@description('Location where the Event Hub Namespace will be created')
param location string = resourceGroup().location

@description('Event Hub Namespace')
param eventHubNamespaceName string 

@description('Event Hub Namespace SKU')
param eventHubNamespaceSku string = 'Basic'

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

var eventHubNamespaceConnectionString = listKeys(eventHubNamespace_ListenSend.id, eventHubNamespace_ListenSend.apiVersion).primaryConnectionString

output eventHubNamespaceConnectionString string = eventHubNamespaceConnectionString
