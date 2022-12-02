using AzureContainerApp.ServiceBusBackgroundWorker;
using AzureContainerApp.ServiceBusBackgroundWorker.Configuration;
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
        services.Configure<QueueConfig>(options =>
            ctx.Configuration.GetRequiredSection(QueueConfig.SectionName).Bind(options));
        services.AddHostedService<Worker>();
    }).Build();
await host.RunAsync();