// using Microsoft.AspNetCore.Builder;
// using Microsoft.AspNetCore.Hosting;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.Extensions.Configuration;
// using Microsoft.Extensions.DependencyInjection;
// using Microsoft.Extensions.Logging;
// using Microsoft.Extensions.Hosting;
// using Expense.Contexts;
// using Expense.Models;
// using zipkin4net;
// using zipkin4net.Tracers.Zipkin;
// using zipkin4net.Transport.Http;
// using zipkin4net.Middleware;
// using Microsoft.AspNetCore.HttpOverrides;
// using System;



// // namespace Expense
// // {
// //   public class Startup
// //   {
// //     public Startup(IConfiguration configuration)
// //     {
// //       Configuration = configuration;
// //     }

// //     public IConfiguration Configuration { get; }

// //     private static ITracer ConfigureTracer(string connection)
// //     {
// //       IStatistics statistics = new Statistics();
// //       TraceManager.SamplingRate = 1.0f;
// //       var httpSender = new HttpZipkinSender(connection, "application/json");
// //       return new ZipkinTracer(httpSender, new JSONSpanSerializer(), statistics);
// //     }

// //     // This method gets called by the runtime. Use this method to add services to the container.
// //     public void ConfigureServices(IServiceCollection services)
// //     {
// //       services.AddDbContext<ExpenseDbContext>(opt =>
// //           opt.UseSqlServer(Configuration.GetConnectionString("ExpensesDatabase")));
// //       services.AddMvc();
// //       services.AddScoped<IExpenseContext, ExpenseContext>();
// //       services.AddTransient<IVersionContext>(s => new VersionContext(Configuration.GetValue<string>("version")));
// //       services.AddLogging(opt =>
// //       {
// //         opt.AddConsole();
// //       });

// //       services.Configure<ForwardedHeadersOptions>(options =>
// //       {
// //         options.ForwardedHeaders =
// //             ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
// //       });
// //     }

// //     // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
// //     public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
// //     {
// //       if (String.IsNullOrEmpty(env.EnvironmentName)) {
// //         // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
// //         app.UseHsts();
// //         app.UseForwardedHeaders();
// //       }
// //       else
// //       {
// //         app.UseDeveloperExceptionPage();
// //         app.UseForwardedHeaders();
// //       }

// //       var lifetime = app.ApplicationServices.GetService<IHostApplicationLifetime>();
// //       IStatistics statistics = new Statistics();

// //       lifetime.ApplicationStarted.Register(() =>
// //       {
// //         var logger = new TracingLogger(loggerFactory, "zipkin4net");
// //         var tracer = ConfigureTracer(Configuration.GetConnectionString("Zipkin"));
// //         TraceManager.Trace128Bits = true;
// //         TraceManager.RegisterTracer(tracer);
// //         TraceManager.Start(logger);
// //       });

// //       lifetime.ApplicationStopped.Register(() => TraceManager.Stop());
// //       app.UseTracing("expense");
// //     }
// //   }
// // }
