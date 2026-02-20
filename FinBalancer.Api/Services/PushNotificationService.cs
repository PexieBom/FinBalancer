using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using FinBalancer.Api.Configuration;
using FinBalancer.Api.Repositories;
using Google.Apis.Auth.OAuth2;

namespace FinBalancer.Api.Services;

/// <summary>Šalje push notifikacije preko FCM. Kad Firebase nije konfiguriran, sve metode no-op.</summary>
public class PushNotificationService
{
    private readonly IDeviceTokenRepository _deviceTokenRepository;
    private readonly PushOptions _options;
    private static FirebaseApp? _firebaseApp;
    private static readonly object _initLock = new();

    public PushNotificationService(
        IDeviceTokenRepository deviceTokenRepository,
        Microsoft.Extensions.Options.IOptions<PushOptions> options)
    {
        _deviceTokenRepository = deviceTokenRepository;
        _options = options.Value;
    }

    private static void EnsureInitialized(PushOptions options)
    {
        if (_firebaseApp != null) return;
        if (!options.IsConfigured) return;

        lock (_initLock)
        {
            if (_firebaseApp != null) return;
            try
            {
                _firebaseApp = FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential.FromFile(options.FirebaseServiceAccountPath)
                });
            }
            catch
            {
                // Log and continue - push will be no-op
            }
        }
    }

    /// <summary>Šalje push notifikaciju svim uređajima korisnika.</summary>
    public async Task SendToUserAsync(Guid userId, string title, string body, string? actionRoute = null)
    {
        EnsureInitialized(_options);
        if (_firebaseApp == null) return;

        var tokens = await _deviceTokenRepository.GetTokensForUserAsync(userId);
        if (tokens.Count == 0) return;

        var data = string.IsNullOrEmpty(actionRoute)
            ? new Dictionary<string, string>()
            : new Dictionary<string, string> { { "action_route", actionRoute } };

        var message = new MulticastMessage
        {
            Tokens = tokens,
            Notification = new Notification { Title = title, Body = body },
            Data = data
        };

        try
        {
            var response = await FirebaseMessaging.GetMessaging(_firebaseApp).SendEachForMulticastAsync(message);
            if (response.FailureCount > 0)
            {
                for (var i = 0; i < response.Responses.Count; i++)
                {
                    if (!response.Responses[i].IsSuccess)
                        await _deviceTokenRepository.RemoveByTokenAsync(tokens[i]);
                }
            }
        }
        catch
        {
            // FCM unavailable - tokens remain, will retry next time
        }
    }
}
