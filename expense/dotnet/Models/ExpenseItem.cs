using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace Expense.Models
{
    public class ExpenseItem
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string TripId { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal Cost { get; set; }
        public string Currency {get; set; }

        public DateTime? Date { get; set; }
        public bool Reimbursable { get; set; } = false;
    }
}