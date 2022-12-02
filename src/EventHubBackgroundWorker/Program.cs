using AzureContainerApp.EventHubBackgroundWorker;
using AzureContainerApp.EventHubBackgroundWorker.Configuration;
using Microsoft.Extensions.Logging.Console;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureLogging((ctx, logging) =>
    {
        logging.ClearProviders();
        logging.AddConsole(options => { options.FormatterName = ConsoleFormatterNames.Simple; });
    })
    .ConfigureServices((ctx, services) =>
    {
        services.Configure<BlobConfig>(options =>
            ctx.Configuration.GetRequiredSection(BlobConfig.SectionName).Bind(options));
        services.Configure<EventHubConfig>(options =>
            ctx.Configuration.GetRequiredSection(EventHubConfig.SectionName).Bind(options));
        services.AddHostedService<Worker>();
    }).Build();
await host.RunAsync();