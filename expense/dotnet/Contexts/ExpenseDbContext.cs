using expense.Models;
using Microsoft.EntityFrameworkCore;

namespace expense.Contexts;
public class ExpenseDbContext : DbContext
{
    public ExpenseDbContext(DbContextOptions<ExpenseDbContext> options) : base(options)
    {
    }

    public DbSet<ExpenseItem> ExpenseItems { get; set; }
}