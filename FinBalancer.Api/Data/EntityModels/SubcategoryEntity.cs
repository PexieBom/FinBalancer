namespace FinBalancer.Api.Data;

public class SubcategoryEntity
{
    public Guid Id { get; set; }
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
}
