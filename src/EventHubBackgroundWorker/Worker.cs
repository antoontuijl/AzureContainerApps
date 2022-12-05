using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using AzureContainerApp.EventHubBackgroundWorker.Configuration;
using Microsoft.Extensions.Options;

namespace AzureContainerApp.EventHubBackgroundWorker
{
    public class Worker : BackgroundService
    {
        private readonly BlobConfig _blobConfig;
        private readonly ILogger<Worker> _logger;
        private readonly EventProcessorClient _processor;

        public Worker(IOptions<EventHubConfig> eventHubConfig,
            IOptions<BlobConfig> blobConfig,
            ILogger<Worker> logger)
        {
            _blobConfig = blobConfig.Value;
            _logger = logger;

            var storageConnectionString = _blobConfig.ConnectionString;
            var eventHubContainer = _blobConfig.EventHubContainerName;
            var storageClient = new BlobContainerClient(storageConnectionString, eventHubContainer);

            var consumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;
            var eventHubConnectionString = eventHubConfig.Value.ConnectionString;
            var eventHubName = eventHubConfig.Value.EventHubName;

            _processor = new EventProcessorClient(storageClient, consumerGroup, eventHubConnectionString, eventHubName);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _processor.ProcessEventAsync += ProcessEventHandler;
            _processor.ProcessErrorAsync += ProcessErrorHandler;

            await _processor.StartProcessingAsync();
            _logger.LogInformation("EventHub processor started at: {time}", DateTimeOffset.Now);

            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("EventHub worker running at: {time}", DateTimeOffset.Now);
                await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
            }

            await _processor.StopProcessingAsync();
            _logger.LogInformation("EventHub worker stopped at: {time}", DateTimeOffset.Now);
        }

        private async Task ProcessEventHandler(ProcessEventArgs eventArgs)
        {
            _logger.LogInformation("Event received at: {time}.", DateTimeOffset.Now);

            var fileName = $"eventhub_{Guid.NewGuid()}";
            var blobContainerClient = new BlobContainerClient(_blobConfig.ConnectionString, _blobConfig.ContainerName);
            _logger.LogInformation("Uploading message to blob: {BlobFileName} to container: {ContainerName}", fileName,
                _blobConfig.ContainerName);
            await blobContainerClient.UploadBlobAsync(fileName, eventArgs.Data.EventBody);

            // Update checkpoint in the blob storage so that the app receives only new events the next time it's run
            await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
        }

        private Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            _logger.LogError(eventArgs.Exception, "Message handler encountered an exception");
            _logger.LogDebug("- Operation: {Operation}", eventArgs.Operation);
            _logger.LogDebug("- PartitionId: {PartitionId}", eventArgs.PartitionId);
            _logger.LogDebug("- Exception: {Exception}", eventArgs.Exception);

            return Task.CompletedTask;
        }
    }
}