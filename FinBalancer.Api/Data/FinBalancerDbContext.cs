using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Data;

/// <summary>
/// EF Core DbContext za PostgreSQL.
/// Database-first: schema je definirana u DatabaseSchema/*.sql.
/// Scaffold: dotnet ef dbcontext scaffold "Host=...;Database=finbalancer;..." Npgsql.EntityFrameworkCore.PostgreSQL -o Data/EntityModels -c FinBalancerDbContext
/// </summary>
public class FinBalancerDbContext : DbContext
{
    public FinBalancerDbContext(DbContextOptions<FinBalancerDbContext> options)
        : base(options)
    {
    }

    public DbSet<UserEntity> Users => Set<UserEntity>();
    public DbSet<WalletEntity> Wallets => Set<WalletEntity>();
    public DbSet<TransactionEntity> Transactions => Set<TransactionEntity>();
    public DbSet<CategoryEntity> Categories => Set<CategoryEntity>();
    public DbSet<SubcategoryEntity> Subcategories => Set<SubcategoryEntity>();
    public DbSet<CustomCategoryEntity> CustomCategories => Set<CustomCategoryEntity>();
    public DbSet<GoalEntity> Goals => Set<GoalEntity>();
    public DbSet<ProjectEntity> Projects => Set<ProjectEntity>();
    public DbSet<WalletBudgetEntity> WalletBudgets => Set<WalletBudgetEntity>();
    public DbSet<AccountLinkEntity> AccountLinks => Set<AccountLinkEntity>();
    public DbSet<RefreshTokenEntity> RefreshTokens => Set<RefreshTokenEntity>();
    public DbSet<AccessTokenEntity> AccessTokens => Set<AccessTokenEntity>();
    public DbSet<NotificationRequestEntity> NotificationRequests => Set<NotificationRequestEntity>();
    public DbSet<InAppNotificationEntity> InAppNotifications => Set<InAppNotificationEntity>();
    public DbSet<SubscriptionPlanEntity> SubscriptionPlans => Set<SubscriptionPlanEntity>();
    public DbSet<UserSubscriptionEntity> UserSubscriptions => Set<UserSubscriptionEntity>();
    public DbSet<UserPreferenceEntity> UserPreferences => Set<UserPreferenceEntity>();
    public DbSet<UnlockedAchievementEntity> UnlockedAchievements => Set<UnlockedAchievementEntity>();
    public DbSet<SchemaVersionEntity> SchemaVersions => Set<SchemaVersionEntity>();
    public DbSet<SubscriptionPurchaseEntity> SubscriptionPurchases => Set<SubscriptionPurchaseEntity>();
    public DbSet<UserEntitlementEntity> UserEntitlements => Set<UserEntitlementEntity>();
    public DbSet<WebhookEventEntity> WebhookEvents => Set<WebhookEventEntity>();
    public DbSet<DeviceTokenEntity> DeviceTokens => Set<DeviceTokenEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserEntity>(e =>
        {
            e.ToTable("users");
            e.HasKey(x => x.Id);
            e.Property(x => x.Email).HasMaxLength(255);
            e.Property(x => x.DisplayName).HasMaxLength(255);
        });

        modelBuilder.Entity<WalletEntity>(e =>
        {
            e.ToTable("wallets");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId);
        });

        modelBuilder.Entity<TransactionEntity>(e =>
        {
            e.ToTable("transactions");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId);
            e.HasIndex(x => x.WalletId);
            e.HasIndex(x => x.DateCreated);
            e.Property(x => x.Tags).HasColumnType("jsonb");
        });

        modelBuilder.Entity<CategoryEntity>(e =>
        {
            e.ToTable("categories");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<SubcategoryEntity>(e =>
        {
            e.ToTable("subcategories");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<CustomCategoryEntity>(e =>
        {
            e.ToTable("custom_categories");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<GoalEntity>(e =>
        {
            e.ToTable("goals");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<ProjectEntity>(e =>
        {
            e.ToTable("projects");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<WalletBudgetEntity>(e =>
        {
            e.ToTable("wallet_budgets");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<AccountLinkEntity>(e =>
        {
            e.ToTable("account_links");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<RefreshTokenEntity>(e =>
        {
            e.ToTable("refresh_tokens");
            e.HasKey(x => x.Token);
        });

        modelBuilder.Entity<AccessTokenEntity>(e =>
        {
            e.ToTable("access_tokens");
            e.HasKey(x => x.Token);
        });

        modelBuilder.Entity<NotificationRequestEntity>(e =>
        {
            e.ToTable("notification_requests");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<InAppNotificationEntity>(e =>
        {
            e.ToTable("in_app_notifications");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<SubscriptionPlanEntity>(e =>
        {
            e.ToTable("subscription_plans");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<UserSubscriptionEntity>(e =>
        {
            e.ToTable("user_subscriptions");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<UserPreferenceEntity>(e =>
        {
            e.ToTable("user_preferences");
            e.HasKey(x => x.UserId);
        });

        modelBuilder.Entity<UnlockedAchievementEntity>(e =>
        {
            e.ToTable("unlocked_achievements");
            e.HasKey(x => x.Id);
        });

        modelBuilder.Entity<SchemaVersionEntity>(e =>
        {
            e.ToTable("schema_version");
            e.HasKey(x => x.Version);
        });

        modelBuilder.Entity<SubscriptionPurchaseEntity>(e =>
        {
            e.ToTable("subscription_purchases");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.UserId, x.Platform, x.ExternalId });
            e.HasIndex(x => new { x.Platform, x.ExternalId }).IsUnique();
            e.Property(x => x.RawPayload).HasColumnType("jsonb");
        });

        modelBuilder.Entity<UserEntitlementEntity>(e =>
        {
            e.ToTable("user_entitlements");
            e.HasKey(x => x.UserId);
        });

        modelBuilder.Entity<WebhookEventEntity>(e =>
        {
            e.ToTable("webhook_events");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.Provider, x.EventId }).IsUnique();
        });

        modelBuilder.Entity<DeviceTokenEntity>(e =>
        {
            e.ToTable("device_tokens");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId);
            e.HasIndex(x => new { x.UserId, x.Token }).IsUnique();
        });
    }
}
