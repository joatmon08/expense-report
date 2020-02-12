using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Consul;
using System.IO;
using System;

namespace Toggle
{
  public class ToggleClient : IToggleClient
  {
    private readonly ConsulClient _consulClient;
    private readonly string _consulAddress;
    private readonly string _consulTemplateFile;
    public ToggleClient(string consulAddress, ConsulClient consulClient, string consulTemplateFile)
    {
      _consulClient = consulClient;
      _consulAddress = consulAddress;
      _consulTemplateFile = consulTemplateFile;
    }

    async Task <bool> GetConsulHTTPToggle(string name) {
      var getPair = await _consulClient.KV.Get("toggles/" + name);
      if (getPair.StatusCode != System.Net.HttpStatusCode.OK)
      {
        return false;
      }
      var value = Encoding.UTF8.GetString(getPair.Response.Value, 0, getPair.Response.Value.Length);
      return TransformToggleValueToBoolean(value);
    }

    bool TransformToggleValueToBoolean(string value) {
      if (value.Contains("true"))
      {
        return true;
      }
      return false;
    }

    async Task<string[]> ReadLines() {
      try {
        using (var reader = File.OpenText(_consulTemplateFile))
        {
            var fileText = await reader.ReadToEndAsync();
            return fileText.Split(new[] { Environment.NewLine }, StringSplitOptions.None);
        }
      }
      catch {
        return new string[0];
      }
    }

    async Task <bool> GetConsulTemplateToggle(string name) {
      var lines = await ReadLines();
      foreach (string line in lines) {
        if (line.Contains(name)) {
          return TransformToggleValueToBoolean(line);
        }
      }
      return false;
    }

    public async Task<bool> GetToggleValue(string name)
    {
      return await GetConsulTemplateToggle(name);
    }

    public async Task<bool> ToggleForExperiment(string name)
    {
      HttpResponseMessage result = await new HttpClient().GetAsync(_consulAddress + "/v1/config/service-router/" + name).ConfigureAwait(false);
      if (result.StatusCode != System.Net.HttpStatusCode.OK)
      {
        return false;
      }
      return true;
    }

    public async Task<bool> ToggleForDatacenter()
    {
      var getPair = await _consulClient.KV.Get("toggles/datacenters");
      if (getPair.StatusCode == System.Net.HttpStatusCode.NotFound)
      {
        return false;
      }
      var datacenterList = Encoding.UTF8.GetString(getPair.Response.Value, 0, getPair.Response.Value.Length);
      var getDatacenters = await _consulClient.Catalog.Datacenters();
      return datacenterList.Contains(getDatacenters.Response[0]);
    }
  }
}