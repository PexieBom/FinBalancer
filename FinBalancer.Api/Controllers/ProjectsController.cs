using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private readonly ProjectService _projectService;

    public ProjectsController(ProjectService projectService)
    {
        _projectService = projectService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Project>>> Get()
    {
        var projects = await _projectService.GetAllAsync();
        return Ok(projects.OrderBy(p => p.Name));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<Project>> GetById(Guid id)
    {
        var project = await _projectService.GetByIdAsync(id);
        if (project == null) return NotFound();
        return Ok(project);
    }

    [HttpPost]
    public async Task<ActionResult<Project>> Post([FromBody] Project project)
    {
        if (string.IsNullOrWhiteSpace(project.Name))
            return BadRequest("Name is required");

        var created = await _projectService.CreateAsync(project);
        if (created == null) return Unauthorized();
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<Project>> Put(Guid id, [FromBody] Project project)
    {
        if (id != project.Id) return BadRequest();
        var existing = await _projectService.GetByIdAsync(id);
        if (existing == null) return NotFound();

        var updated = await _projectService.UpdateAsync(project);
        return updated ? Ok(project) : StatusCode(500);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await _projectService.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }
}
