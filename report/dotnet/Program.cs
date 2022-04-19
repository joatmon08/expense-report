using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using swagger.Filters;
using expense.Client;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

var serviceName = builder.Configuration.GetValue<string>("Name");
var serviceVersion = builder.Configuration.GetValue<string>("Version");

var metricsEndpoint = builder.Configuration["MetricsEndpoint"] ?? "http://*:9464/";

var tracingUri = builder.Configuration["Zipkin"] ?? "http://localhost:9411/api/v2/spans";

var expenseUri = builder.Configuration["Expenses"] ?? "http://localhost:5001";

builder.Services.AddOpenTelemetryMetrics(b =>
{
    b
    .AddHttpClientInstrumentation()
    .AddAspNetCoreInstrumentation()
    .AddPrometheusExporter(o =>
    {
        o.StartHttpListener = true;

        // Workaround for issue: https://github.com/open-telemetry/opentelemetry-dotnet/issues/2840
        o.GetType()
            ?.GetField("httpListenerPrefixes", BindingFlags.NonPublic | BindingFlags.Instance)
            ?.SetValue(o, new[] { metricsEndpoint });

        o.ScrapeResponseCacheDurationMilliseconds = 0;
    });
});

builder.Services.AddOpenTelemetryTracing(b =>
{
    b
    .AddSource(serviceName)
    .SetResourceBuilder(
        ResourceBuilder.CreateDefault()
            .AddService(serviceName: serviceName, serviceVersion: serviceVersion))
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
builder.Services.AddSwaggerGen(g => {
    g.DocumentFilter<CustomSwaggerFilter>();
});

// Add http client for expense service.
builder.Services.AddHttpClient<IExpenseClient, ExpenseClient>(c => {
    c.BaseAddress = new Uri(expenseUri);
});

var app = builder.Build();

if (app.Environment.IsProduction() || app.Environment.IsStaging())
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

app.UseOpenTelemetryPrometheusScrapingEndpoint();

app.UseAuthorization();

app.MapControllers();

app.Run();
