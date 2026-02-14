namespace FinBalancer.Api.Models;

public class Subcategory
{
    public Guid Id { get; set; }
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
}
