using Microsoft.AspNetCore.Http;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub - always returns null (verification fails). Replace with real PayPal Webhooks signature verification.
/// </summary>
public class StubPayPalWebhookVerifier : IWebhookVerifier
{
    public string ProviderName => "paypal";
    public Task<Models.WebhookParsedResult?> VerifyAndParseAsync(Stream body, IHeaderDictionary headers, CancellationToken ct = default)
        => Task.FromResult<Models.WebhookParsedResult?>(null);
}
