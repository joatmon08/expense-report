using System.Net.Http.Json;

namespace expense.Client;
public class ExpenseClient : IExpenseClient
{
  private readonly HttpClient _httpClient;
  public ExpenseClient(HttpClient httpClient)
  {
    _httpClient = httpClient;
  }

  public async Task<List<ExpenseItem>> GetExpensesForTrip(string tripId) {
    HttpResponseMessage response = await _httpClient.GetAsync(_httpClient.BaseAddress + "api/expense/trip/" + tripId);
    return await response.Content.ReadFromJsonAsync<List<ExpenseItem>>();
  }

  public async Task<string> GetExpenseVersion() {
    var result = await _httpClient.GetStringAsync(_httpClient.BaseAddress + "api").ConfigureAwait(false);
    return result.ToString();
  }
}
