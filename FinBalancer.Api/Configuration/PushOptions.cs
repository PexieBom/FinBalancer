namespace FinBalancer.Api.Configuration;

public class PushOptions
{
    public const string SectionName = "Push";

    /// <summary>Puna staza do Firebase service account JSON datoteke (npr. firebase-adminsdk-xxx.json).</summary>
    public string? FirebaseServiceAccountPath { get; set; }

    public bool IsConfigured => !string.IsNullOrWhiteSpace(FirebaseServiceAccountPath) && File.Exists(FirebaseServiceAccountPath);
}
