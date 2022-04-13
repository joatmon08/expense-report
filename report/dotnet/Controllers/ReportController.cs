using Microsoft.AspNetCore.Mvc;
using report.Models;
using expense.Client;

namespace report.Controllers;

[Route("api/[controller]")]
[ApiController]
[Tags("Report")]

public class ReportController : ControllerBase
{
  private readonly IExpenseClient _client;

  public ReportController(IExpenseClient client)
  {
    _client = client;
  }

  [HttpGet("expense/version")]
  public async Task<ActionResult<string>> GetVersion()
  {
    return await _client.GetExpenseVersion();
  }

  [HttpGet("trip/{id}")]
  public async Task<ActionResult<ReportTotal>> GetReportForTrip(string id)
  {
    var items = await _client.GetExpensesForTrip(id);
    List<ExpenseItem> copied = new List<ExpenseItem>(items);
    var report = CreateReport(id, copied);
    if (report == null)
    {
      return NotFound();
    }
    return report;
  }

  private ReportTotal CreateReport(string tripId, IList<ExpenseItem> items)
  {
    decimal total = getTotal(items);

    ReportTotal reportTotal = new ReportTotal
    {
      TripId = tripId,
      Total = total,
      Expenses = items
    };

    addNumItems(reportTotal);
    // Uncomment for report-v3 build
    addTotalReimbursable(reportTotal, items);

    return reportTotal;
  }

  private decimal getTotal(IList<ExpenseItem> items)
  {
    decimal total = 0;
    foreach (ExpenseItem item in items)
    {
      total += item.Cost;
    }
    return total;
  }

  private decimal getTotalReimbursable(IList<ExpenseItem> items) {
    decimal reimbursable = 0;
    foreach (ExpenseItem item in items)
    {
      if (item.Reimbursable == true)
      {
        reimbursable += item.Cost;
      }
    }
    return reimbursable;
  }

  private void addNumItems(ReportTotal reportTotal)
  {
      reportTotal.NumberOfExpenses = reportTotal.Expenses.Count;
  }

  private void addTotalReimbursable(ReportTotal reportTotal, IList<ExpenseItem> items)
  {
    reportTotal.TotalReimbursable = getTotalReimbursable(items);;
  }
}
