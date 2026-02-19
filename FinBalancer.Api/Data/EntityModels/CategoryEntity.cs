namespace FinBalancer.Api.Data;

public class CategoryEntity
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Translations { get; set; } // JSONB
    public string Icon { get; set; } = string.Empty;
    public string Type { get; set; } = "expense";
}
