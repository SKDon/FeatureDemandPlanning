using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
        IEnumerable<Gateway> ListGateways(ProgrammeFilter programmeFilter);
        IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter);
        IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter);
        IEnumerable<ModelTrim> ListTrim(ProgrammeFilter filter);
        IEnumerable<Feature> ListFeatures(ProgrammeFilter filter);
        IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter);

        PagedResults<EngineCodeMapping> ListEngineCodeMappings(EngineCodeFilter filter);
        EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping);

        Task<FdpDerivative> DeleteFdpDerivative(FdpDerivative derivativeToDelete);
        Task<FdpDerivative> GetFdpDerivative(DerivativeFilter filter);
        Task<PagedResults<FdpDerivative>> ListFdpDerivatives(DerivativeFilter filter);

        Task<FdpDerivativeMapping> DeleteFdpDerivativeMapping(FdpDerivativeMapping fdpDerivativeMapping);
        Task<FdpDerivativeMapping> GetFdpDerivativeMapping(DerivativeMappingFilter filter);
        Task<PagedResults<FdpDerivativeMapping>> ListFdpDerivativeMappings(DerivativeMappingFilter filter);

        Task<FdpDerivativeMapping> CopyFdpDerivativeMappingToGateway(FdpDerivativeMapping fdpDerivativeMapping, IEnumerable<string> enumerable);

        Task<FdpDerivativeMapping> CopyFdpDerivativeMappingsToGateway(FdpDerivativeMapping fdpDerivativeMapping, IEnumerable<string> enumerable);
    }
}
