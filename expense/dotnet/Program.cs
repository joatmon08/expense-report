using Microsoft.EntityFrameworkCore;
using expense.Contexts;
using expense.Models;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

var databaseFile = Environment
    .GetEnvironmentVariable("DATABASE_FILE") ?? "dbsettings.json";
builder.Configuration
    .AddJsonFile(databaseFile, optional: false, reloadOnChange: true);

var serviceName = builder.Configuration.GetValue<string>("Name");
var serviceVersion = builder.Configuration.GetValue<string>("Version");

var metricsEndpoint = builder.Configuration["MetricsEndpoint"] ?? "http://localhost:9464/";

var tracingUri = builder.Configuration["Zipkin"] ?? "http://localhost:9411/api/v2/spans";

builder.Services.AddOpenTelemetryMetrics(b =>
{
    b
    .AddPrometheusExporter(o =>
    {
        o.StartHttpListener = true;
        o.HttpListenerPrefixes = new string[] { metricsEndpoint };
    })
    .AddHttpClientInstrumentation()
    .AddAspNetCoreInstrumentation();
});

builder.Services.AddOpenTelemetryTracing(b =>
{
    b
    .AddSource(serviceName)
    .SetResourceBuilder(
        ResourceBuilder.CreateDefault()
            .AddService(serviceName: serviceName, serviceVersion: serviceVersion))
    .AddSqlClientInstrumentation(o =>
    {
        o.SetDbStatementForText = true;
    })
    .AddHttpClientInstrumentation()
    .AddAspNetCoreInstrumentation()
    .AddZipkinExporter(o =>
    {
        o.Endpoint = new Uri(tracingUri);
    });
});

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<ExpenseDbContext>(opt =>
    opt.UseSqlServer(builder.Configuration.GetConnectionString("ExpensesDatabase")));

builder.Services.AddScoped<IExpenseContext, ExpenseContext>();
builder.Services.AddTransient<IVersionContext>(s => new VersionContext(
    serviceVersion));


var app = builder.Build();

if (app.Environment.IsProduction())
{
    app.UseExceptionHandler("/Error");
    app.UseForwardedHeaders();
    app.UseHsts();
}
else
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
    app.UseForwardedHeaders();
}

app.UseAuthorization();

app.MapControllers();

app.Run();
