using FinBalancer.Api.Models;
using Microsoft.AspNetCore.Http;

namespace FinBalancer.Api.Services.Billing;

public interface IWebhookVerifier
{
    string ProviderName { get; }
    Task<WebhookParsedResult?> VerifyAndParseAsync(Stream body, IHeaderDictionary headers, CancellationToken ct = default);
}
