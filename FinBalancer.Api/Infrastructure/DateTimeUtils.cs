namespace FinBalancer.Api.Infrastructure;

/// <summary>Osigurava da svi DateTime vrijednosti za PostgreSQL budu UTC.</summary>
public static class DateTimeUtils
{
    /// <summary>Pretvara DateTime u UTC. Ako je Unspecified, tretira se kao UTC (SpecifyKind).</summary>
    public static DateTime ToUtc(DateTime value)
    {
        if (value.Kind == DateTimeKind.Utc) return value;
        if (value.Kind == DateTimeKind.Local) return value.ToUniversalTime();
        return DateTime.SpecifyKind(value, DateTimeKind.Utc);
    }

    /// <summary>Pretvara nullable DateTime u UTC. Vraća null ako je input null.</summary>
    public static DateTime? ToUtc(DateTime? value) =>
        value.HasValue ? ToUtc(value.Value) : null;
}
