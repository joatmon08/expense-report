namespace expense.Models;

public interface IVersionContext
{
    Task<string> GetVersion();
}