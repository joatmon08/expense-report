using Newtonsoft.Json;
using System.Collections.Generic;
using Expense.Models;
using System.Threading.Tasks;
using System.Net.Http;

namespace Expense.Client
{
  public class ExpenseClient : IExpenseClient
  {
    private readonly HttpClient _httpClient;
    public ExpenseClient(HttpClient httpClient)
    {
      _httpClient = httpClient;
    }

    public async Task<List<ExpenseItem>> GetExpensesForTrip(string tripId) {
      var result = await _httpClient.GetStringAsync(_httpClient.BaseAddress + "api/expense/trip/" + tripId).ConfigureAwait(false);
      return JsonConvert.DeserializeObject<List<ExpenseItem>>(result);
    }

    public async Task<string> GetExpenseVersion() {
      var result = await _httpClient.GetStringAsync(_httpClient.BaseAddress + "api").ConfigureAwait(false);
      return result.ToString();
    }
  }
}