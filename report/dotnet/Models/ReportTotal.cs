using Expense.Models;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace Report.Models
{
    public class ReportTotal
    {
        public string TripId { get; set; }
        public IList<ExpenseItem> Expenses { get; set; } = new List<ExpenseItem>();
        public decimal Total { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public int? NumberOfExpenses { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public decimal? TotalReimbursable { get; set; }
    }
}