namespace AzureContainerApp.ServiceBusBackgroundWorker.Configuration;

public class BlobConfig
{
    public const string SectionName = "BlobConfig";
    public string ConnectionString { get; set; } = null!;
    public string ContainerName { get; set; } = null!;
}
