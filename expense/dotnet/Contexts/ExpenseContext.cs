using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using expense.Models;
namespace expense.Contexts;

public class ExpenseContext : BaseContext, IExpenseContext
{
    public ExpenseContext(ExpenseDbContext context) : base(context)
    {
    }

    public async Task<ActionResult<IEnumerable<ExpenseItem>>> ListAsync()
    {
        return await _context.ExpenseItems.ToListAsync();
    }

    public async Task<ActionResult<IEnumerable<ExpenseItem>>> ListAsyncByTripId(string tripId)
    {
        var items = await _context.ExpenseItems.Where(e => e.TripId == tripId).ToListAsync();
        return items;
    }

    public async Task<ExpenseItem> GetExpense(string id)
    {
        return await _context.ExpenseItems.FindAsync(id);
    }

    public async Task<int> AddExpenseItem(ExpenseItem item)
    {
        item.Id = Guid.NewGuid().ToString();
        _context.ExpenseItems.Add(item);
        return await _context.SaveChangesAsync();
    }

    public async Task<int> UpdateExpenseItem(ExpenseItem item)
    {
        _context.Entry(item).State = EntityState.Modified;
        return await _context.SaveChangesAsync();
    }

    public async Task<int> DeleteExpenseItem(ExpenseItem item)
    {
        _context.ExpenseItems.Remove(item);
        return await _context.SaveChangesAsync();
    }
}