using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.BusinessObjects.Context;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IVehicleDataContext
    {
        IVehicle GetVehicle(VehicleFilter filter);
        IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter);
        IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter);

        PagedResults<EngineCodeMapping> ListEngineCodeMappings(EngineCodeFilter filter);
        EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping);
    }
}
