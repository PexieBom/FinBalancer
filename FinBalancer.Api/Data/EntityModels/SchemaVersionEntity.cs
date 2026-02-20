namespace FinBalancer.Api.Data;

public class SchemaVersionEntity
{
    public int Version { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime AppliedAt { get; set; }
}
