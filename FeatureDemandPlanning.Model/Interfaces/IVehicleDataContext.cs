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
        IVehicle GetVehicle(ProgrammeFilter filter);

        IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter);
        
        IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter);
        Programme GetProgramme(ProgrammeFilter filter);

        IEnumerable<ModelBody> ListBodies(ProgrammeFilter filter);
        IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter);
        IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter);
        IEnumerable<ModelTrim> ListTrim(ProgrammeFilter filter);
        IEnumerable<Feature> ListFeatures(ProgrammeFilter filter);
        IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter);

        PagedResults<EngineCodeMapping> ListEngineCodeMappings(EngineCodeFilter filter);
        EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping);
    }
}
