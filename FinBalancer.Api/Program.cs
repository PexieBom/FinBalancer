using FinBalancer.Api.Configuration;
using FinBalancer.Api.HostedServices;
using FinBalancer.Api.Data;
using FinBalancer.Api.Filters;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Middleware;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Repositories.Db;
using FinBalancer.Api.Repositories.Json;
using FinBalancer.Api.Services;
using FinBalancer.Api.Services.Billing;
using Microsoft.EntityFrameworkCore;

// Npgsql: tretiraj DateTimeKind.Unspecified kao UTC (za timestamptz)
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers(options =>
{
    options.Filters.Add<ApiErrorResultFilter>();
})
    .AddJsonOptions(opts => opts.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter()));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

// Config
builder.Services.Configure<StorageOptions>(
    builder.Configuration.GetSection(StorageOptions.SectionName));
builder.Services.Configure<PushOptions>(
    builder.Configuration.GetSection(PushOptions.SectionName));

var useMockData = builder.Configuration.GetValue<bool>("Storage:UseMockData");

if (useMockData)
{
    builder.Services.AddSingleton<JsonStorageService>();
    builder.Services.AddScoped<ITransactionRepository, JsonTransactionRepository>();
    builder.Services.AddScoped<IWalletRepository, JsonWalletRepository>();
    builder.Services.AddScoped<ICategoryRepository, JsonCategoryRepository>();
    builder.Services.AddScoped<IUserRepository, JsonUserRepository>();
    builder.Services.AddScoped<INotificationRequestRepository, JsonNotificationRequestRepository>();
    builder.Services.AddScoped<ISubcategoryRepository, JsonSubcategoryRepository>();
    builder.Services.AddScoped<IGoalRepository, JsonGoalRepository>();
    builder.Services.AddScoped<IAchievementRepository, JsonAchievementRepository>();
    builder.Services.AddScoped<IRefreshTokenRepository, JsonRefreshTokenRepository>();
    builder.Services.AddScoped<IProjectRepository, JsonProjectRepository>();
    builder.Services.AddScoped<ICustomCategoryRepository, JsonCustomCategoryRepository>();
    builder.Services.AddScoped<ISubscriptionRepository, JsonSubscriptionRepository>();
    builder.Services.AddScoped<ISubscriptionPlanRepository, JsonSubscriptionPlanRepository>();
    builder.Services.AddScoped<IWalletBudgetRepository, JsonWalletBudgetRepository>();
    builder.Services.AddScoped<IAccountLinkRepository, JsonAccountLinkRepository>();
    builder.Services.AddScoped<IInAppNotificationRepository, JsonInAppNotificationRepository>();
    builder.Services.AddScoped<IDeviceTokenRepository, JsonDeviceTokenRepository>();
    builder.Services.AddScoped<ISubscriptionPurchaseRepository, NullSubscriptionPurchaseRepository>();
    builder.Services.AddScoped<IUserEntitlementRepository, NullUserEntitlementRepository>();
    builder.Services.AddScoped<IWebhookEventRepository, NullWebhookEventRepository>();
    builder.Services.AddScoped<IAccessTokenRepository, NullAccessTokenRepository>();
    builder.Services.AddScoped<IUserPreferencesRepository, JsonUserPreferencesRepository>();
}
else
{
    var conn = builder.Configuration.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("ConnectionStrings:DefaultConnection is required when UseMockData is false.");
    builder.Services.AddDbContext<FinBalancerDbContext>(opts =>
        opts.UseNpgsql(conn).UseSnakeCaseNamingConvention());
    builder.Services.AddScoped<ITransactionRepository, DbTransactionRepository>();
    builder.Services.AddScoped<IWalletRepository, DbWalletRepository>();
    builder.Services.AddScoped<ICategoryRepository, DbCategoryRepository>();
    builder.Services.AddScoped<IUserRepository, DbUserRepository>();
    builder.Services.AddScoped<INotificationRequestRepository, DbNotificationRequestRepository>();
    builder.Services.AddScoped<ISubcategoryRepository, DbSubcategoryRepository>();
    builder.Services.AddScoped<IGoalRepository, DbGoalRepository>();
    builder.Services.AddScoped<IAchievementRepository, DbAchievementRepository>();
    builder.Services.AddScoped<IRefreshTokenRepository, DbRefreshTokenRepository>();
    builder.Services.AddScoped<IProjectRepository, DbProjectRepository>();
    builder.Services.AddScoped<ICustomCategoryRepository, DbCustomCategoryRepository>();
    builder.Services.AddScoped<ISubscriptionRepository, DbSubscriptionRepository>();
    builder.Services.AddScoped<ISubscriptionPlanRepository, DbSubscriptionPlanRepository>();
    builder.Services.AddScoped<IWalletBudgetRepository, DbWalletBudgetRepository>();
    builder.Services.AddScoped<IAccountLinkRepository, DbAccountLinkRepository>();
    builder.Services.AddScoped<IInAppNotificationRepository, DbInAppNotificationRepository>();
    builder.Services.AddScoped<IDeviceTokenRepository, DbDeviceTokenRepository>();
    builder.Services.AddScoped<ISubscriptionPurchaseRepository, DbSubscriptionPurchaseRepository>();
    builder.Services.AddScoped<IUserEntitlementRepository, DbUserEntitlementRepository>();
    builder.Services.AddScoped<IWebhookEventRepository, DbWebhookEventRepository>();
    builder.Services.AddScoped<IAccessTokenRepository, DbAccessTokenRepository>();
    builder.Services.AddScoped<IUserPreferencesRepository, DbUserPreferencesRepository>();
}

builder.Services.AddScoped<TransactionService>();
builder.Services.AddScoped<WalletService>();
builder.Services.AddScoped<CategoryService>();
builder.Services.AddScoped<StatisticsService>();
builder.Services.AddScoped<AdvancedStatisticsService>();
builder.Services.AddScoped<GoalService>();
builder.Services.AddScoped<ProjectService>();
builder.Services.AddScoped<AchievementService>();
builder.Services.AddScoped<UserPreferencesService>();
builder.Services.AddScoped<IAuthService, MockAuthService>();
builder.Services.AddScoped<ISubscriptionValidationService, SubscriptionValidationService>();
builder.Services.AddScoped<SubscriptionService>();
builder.Services.AddScoped<BudgetService>();
builder.Services.AddScoped<AccountLinkService>();
builder.Services.AddScoped<PushNotificationService>();
builder.Services.AddScoped<DeviceTokenService>();
builder.Services.AddScoped<InAppNotificationService>();
builder.Services.AddScoped<BillingService>();
builder.Services.AddScoped<SubscriptionReconciliationService>();
builder.Services.AddHostedService<SubscriptionReconciliationJob>();

// Stub verifiers - replace with real implementations when ready
builder.Services.AddScoped<IApplePurchaseVerifier, StubApplePurchaseVerifier>();
builder.Services.AddScoped<IGooglePurchaseVerifier, StubGooglePurchaseVerifier>();
builder.Services.AddScoped<IPayPalPurchaseVerifier, StubPayPalPurchaseVerifier>();
builder.Services.AddScoped<StubAppleWebhookVerifier>();
builder.Services.AddScoped<StubGoogleWebhookVerifier>();
builder.Services.AddScoped<StubPayPalWebhookVerifier>();

builder.Services.AddHealthChecks();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// CORS mora biti što ranije – posebno za OPTIONS preflight
app.UseCors();
app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<CurrentUserMiddleware>();
app.UseMiddleware<RequireAuthMiddleware>();

var version = typeof(Program).Assembly.GetName().Version?.ToString(3) ?? "1.0.0";
app.MapGet("/", () => Results.Json(new { api = "api.finbalancer.com", version }));
app.MapHealthChecks("/health");

app.MapControllers();

app.Run();
