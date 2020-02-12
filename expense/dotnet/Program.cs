using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace Expense
{
  public class Program
  {
    public static void Main(string[] args)
    {
      CreateWebHostBuilder(args).Build().Run();
    }

    public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
        WebHost.CreateDefaultBuilder(args)
            .UseUrls("http://*:5001")
            .UseStartup<Startup>()
            .ConfigureKestrel((context, options) =>
            {
                options.Limits.MaxRequestHeadersTotalSize = 1048576;
            });
  }
}
