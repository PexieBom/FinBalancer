namespace FinBalancer.Api.Models;

public class Category
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty; // Default/fallback name
    /// <summary>Translations: locale code -> name. e.g. {"en":"Food","hr":"Hrana","de":"Essen"}</summary>
    public Dictionary<string, string>? Translations { get; set; }
    public string Icon { get; set; } = string.Empty;
    public string Type { get; set; } = "expense"; // "income" | "expense"
}
