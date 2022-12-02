namespace AzureContainerApp.EventHubBackgroundWorker.Configuration;

public class BlobConfig
{
    public const string SectionName = "BlobConfig";
    public string ConnectionString { get; set; } = null!;
    public string ContainerName { get; set; } = null!;

    public string EventHubContainerName { get; set; } = null!;
}
