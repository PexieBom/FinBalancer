using FinBalancer.Api.Services;

namespace FinBalancer.Api.HostedServices;

/// <summary>
/// Runs subscription reconciliation periodically (e.g. every hour).
/// Fixes missed webhooks and expires subscriptions past end_time.
/// </summary>
public class SubscriptionReconciliationJob : BackgroundService
{
    private readonly IServiceProvider _services;
    private readonly ILogger<SubscriptionReconciliationJob> _logger;
    private static readonly TimeSpan Interval = TimeSpan.FromHours(1);

    public SubscriptionReconciliationJob(IServiceProvider services, ILogger<SubscriptionReconciliationJob> logger)
    {
        _services = services;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _services.CreateScope();
                var svc = scope.ServiceProvider.GetRequiredService<SubscriptionReconciliationService>();
                await svc.RunAsync(stoppingToken);
                _logger.LogDebug("Subscription reconciliation completed");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Subscription reconciliation failed");
            }

            await Task.Delay(Interval, stoppingToken);
        }
    }
}
