using FinBalancer.Api.Configuration;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Middleware;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Repositories.Json;
using FinBalancer.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddJsonOptions(opts => opts.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter()));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

// Config
builder.Services.Configure<StorageOptions>(
    builder.Configuration.GetSection(StorageOptions.SectionName));

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
}
else
{
    // TODO: Add PostgreSQL/real DB repositories when implemented
    // builder.Services.AddScoped<ITransactionRepository, DbTransactionRepository>();
    // builder.Services.AddScoped<IWalletRepository, DbWalletRepository>();
    // builder.Services.AddScoped<ICategoryRepository, DbCategoryRepository>();
    throw new InvalidOperationException(
        "Storage:UseMockData must be true. Database storage not yet implemented.");
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
builder.Services.AddScoped<InAppNotificationService>();

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

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseMiddleware<CurrentUserMiddleware>();
app.MapControllers();

app.Run();
