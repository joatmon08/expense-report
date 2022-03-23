using expense.Models;

namespace expense.Client;

public interface IExpenseClient
{
    Task<List<ExpenseItem>> GetExpensesForTrip(string tripId);
    Task<string> GetExpenseVersion();
}