namespace FinBalancer.Api.Data;

public class CustomCategoryEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Type { get; set; } = "expense";
    public string Icon { get; set; } = "custom";
}
