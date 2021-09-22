using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Expense.Client;
using System;
using Microsoft.Extensions.Logging;
using zipkin4net;
using zipkin4net.Tracers.Zipkin;
using zipkin4net.Transport.Http;
using zipkin4net.Middleware;


namespace Report
{
  public class Startup
  {
    public Startup(IConfiguration configuration)
    {
      Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
      services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);
      services.AddHttpClient<IExpenseClient, ExpenseClient>(client =>
      {
          client.BaseAddress = new Uri(Configuration.GetConnectionString("Expenses"));
      }).AddHttpMessageHandler(provider => TracingHandler.WithoutInnerHandler("report"));
      services.AddLogging(opt =>
      {
            opt.AddConsole();
      });
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
    {
      if (env.IsDevelopment())
      {
        app.UseDeveloperExceptionPage();
      }
      else
      {
        // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
        app.UseHsts();
      }

      var lifetime = app.ApplicationServices.GetService<IApplicationLifetime> ();
      IStatistics statistics = new Statistics();

      lifetime.ApplicationStarted.Register (() => {
          TraceManager.SamplingRate = 1.0f;
          var logger = new TracingLogger(loggerFactory, "zipkin4net");
          var httpSender = new HttpZipkinSender(Configuration.GetConnectionString("Zipkin"), "application/json");
          var tracer = new ZipkinTracer(httpSender, new JSONSpanSerializer (), statistics);
          TraceManager.Trace128Bits = true;
          TraceManager.RegisterTracer(tracer);
          TraceManager.Start(logger);
      });

      lifetime.ApplicationStopped.Register(() => TraceManager.Stop());
      app.UseTracing("report");

      app.UseMvc();
    }
  }
}
