using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class CategoryService
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly ICustomCategoryRepository _customCategoryRepository;

    public CategoryService(ICategoryRepository categoryRepository, ICustomCategoryRepository customCategoryRepository)
    {
        _categoryRepository = categoryRepository;
        _customCategoryRepository = customCategoryRepository;
    }

    public async Task<List<Category>> GetCategoriesAsync(string? locale = null, Guid? userId = null)
    {
        var categories = await _categoryRepository.GetOrSeedDefaultsAsync();
        if (!string.IsNullOrEmpty(locale))
        {
            var lang = locale.Length >= 2 ? locale[..2].ToLowerInvariant() : locale.ToLowerInvariant();
            foreach (var c in categories)
            {
                if (c.Translations != null && c.Translations.TryGetValue(lang, out var name))
                    c.Name = name;
            }
        }
        var custom = await _customCategoryRepository.GetByUserIdAsync(userId ?? Guid.Empty);
        foreach (var cc in custom)
        {
            categories.Add(new Category { Id = cc.Id, Name = cc.Name, Icon = "custom", Type = cc.Type });
        }
        return categories;
    }

    public async Task<Category?> AddCustomCategoryAsync(string name, string type, Guid? userId = null)
    {
        if (!userId.HasValue) return null;
        var cc = new CustomCategory { UserId = userId.Value, Name = name, Type = type };
        var added = await _customCategoryRepository.AddAsync(cc);
        return new Category { Id = added.Id, Name = added.Name, Icon = "custom", Type = added.Type };
    }

    public async Task<bool> DeleteCustomCategoryAsync(Guid id, Guid? userId = null)
    {
        return await _customCategoryRepository.DeleteAsync(id, userId ?? Guid.Empty);
    }
}
