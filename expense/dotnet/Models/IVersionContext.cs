using System.Threading.Tasks;

namespace Expense.Models
{
    public interface IVersionContext
    {
        Task<string> GetVersion();
    }
}