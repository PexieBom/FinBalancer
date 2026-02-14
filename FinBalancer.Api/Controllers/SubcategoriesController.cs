using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SubcategoriesController : ControllerBase
{
    private readonly ISubcategoryRepository _repository;

    public SubcategoriesController(ISubcategoryRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<List<Subcategory>>> Get([FromQuery] Guid? categoryId)
    {
        var list = categoryId.HasValue
            ? await _repository.GetByCategoryAsync(categoryId.Value)
            : await _repository.GetAllAsync();
        return Ok(list);
    }

    [HttpPost]
    public async Task<ActionResult<Subcategory>> Post([FromBody] Subcategory subcategory)
    {
        if (string.IsNullOrWhiteSpace(subcategory.Name))
            return BadRequest("Name required");
        var created = await _repository.AddAsync(subcategory);
        return CreatedAtAction(nameof(Get), created);
    }
}
