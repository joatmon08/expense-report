using expense.Models;

namespace expense.Contexts;

public class VersionContext : IVersionContext
{
    protected readonly string _version;

    public VersionContext(string version)
    {
        _version = version;
    }

    public async Task<string> GetVersion()
    {
        return await Task.Run(() => ReturnVersion());
    }


    public string ReturnVersion()
    {
        return _version;
    }
}