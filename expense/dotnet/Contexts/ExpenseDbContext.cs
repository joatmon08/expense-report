using Expense.Models;
using Microsoft.EntityFrameworkCore;

namespace Expense.Contexts
{
    public class ExpenseDbContext : DbContext
    {
        public ExpenseDbContext(DbContextOptions<ExpenseDbContext> options) : base(options)
        {
        }

        public DbSet<ExpenseItem> ExpenseItems { get; set; }
    }
}