using Microsoft.AspNetCore.Http;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub - always returns null (verification fails). Replace with real Google Play Real-time Developer Notifications verification.
/// </summary>
public class StubGoogleWebhookVerifier : IWebhookVerifier
{
    public string ProviderName => "google";
    public Task<Models.WebhookParsedResult?> VerifyAndParseAsync(Stream body, IHeaderDictionary headers, CancellationToken ct = default)
        => Task.FromResult<Models.WebhookParsedResult?>(null);
}
