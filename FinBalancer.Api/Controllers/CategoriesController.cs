using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly CategoryService _categoryService;
    private readonly ICurrentUserService _currentUser;

    public CategoriesController(CategoryService categoryService, ICurrentUserService currentUser)
    {
        _categoryService = categoryService;
        _currentUser = currentUser;
    }

    [HttpGet]
    public async Task<ActionResult<List<Category>>> Get([FromQuery] string? locale)
    {
        var categories = await _categoryService.GetCategoriesAsync(locale, _currentUser.UserId);
        return Ok(categories);
    }

    [HttpPost("custom")]
    public async Task<ActionResult<Category>> AddCustom([FromBody] CustomCategoryRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return BadRequest("Name is required");
        if (request.Type is not "income" and not "expense")
            return BadRequest("Type must be 'income' or 'expense'");
        var cat = await _categoryService.AddCustomCategoryAsync(request.Name, request.Type, _currentUser.UserId);
        if (cat == null) return Unauthorized();
        return CreatedAtAction(nameof(Get), cat);
    }

    [HttpDelete("custom/{id:guid}")]
    public async Task<IActionResult> DeleteCustom(Guid id)
    {
        var deleted = await _categoryService.DeleteCustomCategoryAsync(id, _currentUser.UserId);
        if (!deleted) return NotFound();
        return NoContent();
    }
}

public record CustomCategoryRequest(string Name, string Type);
