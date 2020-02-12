using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using Expense.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using zipkin4net;

namespace Expense.Contexts
{
    public class ExpenseContext: BaseContext, IExpenseContext
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
        var parentTrace = Trace.Current;
        var trace = parentTrace.Child();
        trace.Record(Annotations.LocalOperationStart("database"));
        trace.Record(Annotations.ServiceName("expense"));
        trace.Record(Annotations.Tag("request", "list-expenses"));
        trace.Record(Annotations.Rpc("SELECT"));
        var items = await _context.ExpenseItems.Where(e => e.TripId == tripId).ToListAsync();
        trace.Record(Annotations.LocalOperationStop());
        return items;
      }

      public async Task<ExpenseItem> GetExpense(string id)
      {
          return await _context.ExpenseItems.FindAsync(id);
      }

      public async Task<int> AddExpenseItem(ExpenseItem item) {
        _context.ExpenseItems.Add(item);
        return await _context.SaveChangesAsync();
      }

      public async Task<int> UpdateExpenseItem(ExpenseItem item) {
        _context.Entry(item).State = EntityState.Modified;
        return await _context.SaveChangesAsync();
      }

      public async Task<int> DeleteExpenseItem(ExpenseItem item) {
        _context.ExpenseItems.Remove(item);
        return await _context.SaveChangesAsync();
      }
    }
}