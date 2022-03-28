FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

RUN mkdir -p client/dotnet report/dotnet

# Copy csproj and restore as distinct layers
COPY client/dotnet/*.csproj client/dotnet/.
COPY report/dotnet/*.csproj report/dotnet/.
RUN cd /app/report/dotnet && dotnet restore

# Copy everything else and build
WORKDIR /app
COPY client/dotnet/ client/dotnet/
COPY report/dotnet/ report/dotnet/

WORKDIR /app/report/dotnet
RUN dotnet publish -c Release -o /app/report/dotnet/out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/report/dotnet/out .
EXPOSE 5002
ENTRYPOINT ["dotnet", "report.dll"]