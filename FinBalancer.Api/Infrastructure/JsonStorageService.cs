using System.Text.Json;
using System.Collections.Concurrent;

namespace FinBalancer.Api.Infrastructure;

public class JsonStorageService
{
    private readonly string _dataPath;
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true
    };
    private static readonly ConcurrentDictionary<string, SemaphoreSlim> _fileLocks = new();

    public JsonStorageService(IWebHostEnvironment env)
    {
        _dataPath = Path.Combine(env.ContentRootPath, "Data");
        Directory.CreateDirectory(_dataPath);
    }

    private string GetFilePath(string fileName) => Path.Combine(_dataPath, fileName);

    private SemaphoreSlim GetFileLock(string fileName)
    {
        return _fileLocks.GetOrAdd(fileName, _ => new SemaphoreSlim(1, 1));
    }

    public async Task<List<T>> ReadJsonAsync<T>(string fileName)
    {
        var semaphore = GetFileLock(fileName);
        await semaphore.WaitAsync();
        try
        {
            return await ReadJsonUnsafeAsync<T>(fileName);
        }
        finally
        {
            semaphore.Release();
        }
    }

    public async Task WriteJsonAsync<T>(string fileName, List<T> data)
    {
        var semaphore = GetFileLock(fileName);
        await semaphore.WaitAsync();
        try
        {
            await WriteJsonUnsafeAsync(fileName, data);
        }
        finally
        {
            semaphore.Release();
        }
    }

    internal async Task<List<T>> ReadJsonUnsafeAsync<T>(string fileName)
    {
        var filePath = GetFilePath(fileName);
        if (!File.Exists(filePath))
            return new List<T>();

        var json = await File.ReadAllTextAsync(filePath);
        if (string.IsNullOrWhiteSpace(json))
            return new List<T>();

        var result = JsonSerializer.Deserialize<List<T>>(json, JsonOptions);
        return result ?? new List<T>();
    }

    internal async Task WriteJsonUnsafeAsync<T>(string fileName, List<T> data)
    {
        var filePath = GetFilePath(fileName);
        var json = JsonSerializer.Serialize(data, JsonOptions);
        await File.WriteAllTextAsync(filePath, json);
    }

    internal async Task ExecuteInLockAsync(string fileName, Func<Task> action)
    {
        var semaphore = GetFileLock(fileName);
        await semaphore.WaitAsync();
        try
        {
            await action();
        }
        finally
        {
            semaphore.Release();
        }
    }
}
