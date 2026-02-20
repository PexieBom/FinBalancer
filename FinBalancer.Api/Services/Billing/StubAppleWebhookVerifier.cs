using Microsoft.AspNetCore.Http;

namespace FinBalancer.Api.Services.Billing;

public class StubAppleWebhookVerifier : IWebhookVerifier
{
    public string ProviderName => "apple";
    public Task<Models.WebhookParsedResult?> VerifyAndParseAsync(Stream body, IHeaderDictionary headers, CancellationToken ct = default)
        => Task.FromResult<Models.WebhookParsedResult?>(null);
}
