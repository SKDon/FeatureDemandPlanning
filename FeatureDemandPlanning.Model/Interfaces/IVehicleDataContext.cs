using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVehicleDataContext
    {
        IVehicle GetVehicle(VehicleFilter filter);
        IVehicle GetVehicle(ProgrammeFilter filter);

        IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter);
        
        IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter);
        Programme GetProgramme(ProgrammeFilter filter);

        IEnumerable<ModelBody> ListBodies(ProgrammeFilter filter);
        IEnumerable<Derivative> ListDerivatives(ProgrammeFilter filter);
        IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter);
        IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter);
        IEnumerable<ModelTrim> ListTrim(ProgrammeFilter filter);
        IEnumerable<Feature> ListFeatures(ProgrammeFilter filter);
        IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter);

        PagedResults<EngineCodeMapping> ListEngineCodeMappings(EngineCodeFilter filter);
        EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping);
    }
}
