using System.Collections.Generic;
using Expense.Models;
using System.Threading.Tasks;

namespace Expense.Client
{
    public interface IExpenseClient
    {
          Task<List<ExpenseItem>> GetExpensesForTrip(string tripId);
          Task<string> GetExpenseVersion();
    }
}