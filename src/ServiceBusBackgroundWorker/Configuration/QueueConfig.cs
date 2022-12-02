namespace AzureContainerApp.ServiceBusBackgroundWorker.Configuration;

public class QueueConfig
{
    public const string SectionName = "QueueConfig";
    public string ConnectionString { get; set; } = null!;
    public string QueueName { get; set; } = null!;
}
