using Microsoft.AspNetCore.Mvc;
using expense.Models;

namespace expense.Controllers;

[Route("api/[controller]")]
[ApiController]
[Tags("Expense")]
public class ExpenseController : ControllerBase
{
    private readonly IExpenseContext _context;

    public ExpenseController(IExpenseContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ExpenseItem>>> GetExpenseItems()
    {
        return await _context.ListAsync();
    }

    [HttpGet("trip/{tripId}")]
    public async Task<ActionResult<IEnumerable<ExpenseItem>>> GetExpenseItemsForTrip(string tripId)
    {
        var items = await _context.ListAsyncByTripId(tripId);
        return items;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ExpenseItem>> GetExpenseItem(string id)
    {
        var expenseItem = await _context.GetExpense(id);
        if (expenseItem == null)
        {
            return NotFound();
        }
        return expenseItem;
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseItem>> PostExpenseItem(ExpenseItem item)
    {
        await _context.AddExpenseItem(item);
        return CreatedAtAction(nameof(GetExpenseItems), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutExpenseItem(string id, ExpenseItem item)
    {
        if (id != item.Id)
        {
            return BadRequest();
        }

        await _context.UpdateExpenseItem(item);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteExpenseItem(string id)
    {
        var item = await _context.GetExpense(id);
        if (item == null)
        {
            return NotFound();
        }
        await _context.DeleteExpenseItem(item);
        return NoContent();
    }
}