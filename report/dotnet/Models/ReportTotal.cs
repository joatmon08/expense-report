using expense.Client;

namespace report.Models;

public class ReportTotal
{
    public string TripId { get; set; }

    public IList<ExpenseItem> Expenses { get; set; } = new List<ExpenseItem>();

    public decimal Total { get; set; }

    public int? NumberOfExpenses { get; set; }

    // Uncomment for report-v3 build
    public decimal? TotalReimbursable { get; set; }
}