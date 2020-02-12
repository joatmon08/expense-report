using System.Threading.Tasks;

namespace Toggle
{
    public interface IToggleClient
    {
          Task<bool> GetToggleValue(string name);
          Task<bool> ToggleForDatacenter();
          Task<bool> ToggleForExperiment(string name);
    }
}