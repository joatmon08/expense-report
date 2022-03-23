using Microsoft.AspNetCore.Mvc;
using expense.Models;
namespace expense.Controllers;

[Route("api")]
[ApiController]
public class VersionController : ControllerBase
{

    private readonly IVersionContext _context;

    public VersionController(IVersionContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<string>> Version()
    {
        return await _context.GetVersion();
    }
}