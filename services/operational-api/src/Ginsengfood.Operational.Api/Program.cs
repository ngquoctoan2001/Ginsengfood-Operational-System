using Ginsengfood.Operational.SharedKernel;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddProblemDetails();

var app = builder.Build();

app.MapGet(
        "/health",
        () => Results.Ok(new
        {
            status = "ok",
            service = "operational-api",
            project = ScaffoldAssemblyMarker.ProjectName
        }))
    .WithName("OperationalApiHealth");

app.Run();

public partial class Program;
