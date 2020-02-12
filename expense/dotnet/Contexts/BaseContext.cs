namespace Expense.Contexts
{
    public abstract class BaseContext
    {
        protected readonly ExpenseDbContext _context;

        public BaseContext(ExpenseDbContext context)
        {
            _context = context;
        }
    }
}