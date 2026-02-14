using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private readonly IProjectRepository _projectRepository;

    public ProjectsController(IProjectRepository projectRepository)
    {
        _projectRepository = projectRepository;
    }

    [HttpGet]
    public async Task<ActionResult<List<Project>>> Get()
    {
        var projects = await _projectRepository.GetAllAsync();
        return Ok(projects.OrderBy(p => p.Name));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<Project>> GetById(Guid id)
    {
        var project = await _projectRepository.GetByIdAsync(id);
        if (project == null) return NotFound();
        return Ok(project);
    }

    [HttpPost]
    public async Task<ActionResult<Project>> Post([FromBody] Project project)
    {
        if (string.IsNullOrWhiteSpace(project.Name))
            return BadRequest("Name is required");

        var created = await _projectRepository.AddAsync(project);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<Project>> Put(Guid id, [FromBody] Project project)
    {
        if (id != project.Id) return BadRequest();
        var existing = await _projectRepository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        var updated = await _projectRepository.UpdateAsync(project);
        return updated ? Ok(project) : StatusCode(500);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await _projectRepository.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }
}
