namespace AzureContainerApp.Worker.Configuration;

public class EventHubConfig
{
    public const string SectionName = "EventHubConfig";
    public string ConnectionString { get; set; } = null!;
    public string EventHubName { get; set; } = null!;
}
