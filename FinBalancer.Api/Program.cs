using FinBalancer.Api.Configuration;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Repositories.Json;
using FinBalancer.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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
builder.Services.AddScoped<IAuthService, MockAuthService>();

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
app.MapControllers();

app.Run();
