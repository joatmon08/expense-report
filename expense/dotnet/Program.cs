using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.HttpOverrides;
using expense.Contexts;
using expense.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders =
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
});

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<ExpenseDbContext>(opt =>
    opt.UseSqlServer(
        builder.Configuration.GetConnectionString("ExpensesDatabase")));

builder.Services.AddScoped<IExpenseContext, ExpenseContext>();
builder.Services.AddTransient<IVersionContext>(s => new VersionContext(
    builder.Configuration.GetValue<string>("Version")));


var app = builder.Build();

if (!app.Environment.IsDevelopment())
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
