using Ginsengfood.Operational.Contracts;
using Ginsengfood.Operational.Infrastructure;
using Ginsengfood.Operational.SharedKernel;

namespace Ginsengfood.Operational.Scaffold.Tests;

public class ScaffoldMarkerTests
{
    [Fact]
    public void Approved_stack_markers_are_available()
    {
        var contract = new ScaffoldContractMarker(
            ScaffoldAssemblyMarker.ProjectName,
            "API contracts");

        Assert.Equal("Ginsengfood Operational V2", contract.ProjectName);
        Assert.Equal("PostgreSQL", ScaffoldInfrastructureMarker.ApprovedDatabase);
    }
}
