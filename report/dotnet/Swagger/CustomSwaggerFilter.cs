using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace swagger.Filters;

public class CustomSwaggerFilter : IDocumentFilter
{
    public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
    {
        var filteredPaths = new List<string>();
        foreach (var path in swaggerDoc.Paths) {
            // Add the available ops if they are in the postman collection. See path.Value
            foreach (var operation in path.Value.Operations)
            {
                if (operation.Value.Tags.Any(tag => tag.Name.Contains("Expense")))
                {
                    filteredPaths.Add(path.Key);
                }
            }
        }

        filteredPaths.ForEach(x => { swaggerDoc.Paths.Remove(x); });
    }
}