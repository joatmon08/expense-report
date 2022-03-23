using System.Text.Json;
using expense.Models;

namespace expense.Client;

public class ExpenseClient : IExpenseClient
{
  private readonly HttpClient _httpClient;
  public ExpenseClient(HttpClient httpClient)
  {
    _httpClient = httpClient;
  }

  public async Task<List<ExpenseItem>> GetExpensesForTrip(string tripId) {
    var result = await _httpClient.GetStringAsync(_httpClient.BaseAddress + "api/expense/trip/" + tripId).ConfigureAwait(false);
    return JsonSerializer.Deserialize<List<ExpenseItem>>(result);
  }

  public async Task<string> GetExpenseVersion() {
    var result = await _httpClient.GetStringAsync(_httpClient.BaseAddress + "api").ConfigureAwait(false);
    return result.ToString();
  }
}