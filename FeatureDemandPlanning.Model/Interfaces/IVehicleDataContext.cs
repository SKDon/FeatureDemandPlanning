using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVehicleDataContext
    {
        Task<IVehicle> GetVehicle(VehicleFilter filter);
        Task<IVehicle> GetVehicle(ProgrammeFilter filter);

        IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter);
        
        IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter);
        Programme GetProgramme(ProgrammeFilter filter);

        Task<IEnumerable<FdpModel>> ListAvailableModels(ProgrammeFilter filter);
        IEnumerable<ModelBody> ListBodies(ProgrammeFilter filter);
        IEnumerable<Derivative> ListDerivatives(DerivativeFilter filter);
        IEnumerable<Gateway> ListGateways(ProgrammeFilter filter);
        IEnumerable<OXODoc> ListPublishedDocuments(ProgrammeFilter filter);
        IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter);
        IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter);
        IEnumerable<FdpTrimMapping> ListTrim(TrimFilter filter);
        IEnumerable<FdpTrimMapping> ListOxoTrim(TrimFilter filter); 
        Task<IEnumerable<Feature>> ListFeatures(ProgrammeFilter filter); // Get rid of this one
        Task<IEnumerable<FdpFeature>> ListFeatures(FeatureFilter filter);
        IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter);
        IEnumerable<TrimLevel> ListTrimLevels(ProgrammeFilter programmeFilter);

        // Derivatives and mappings

        Task<FdpDerivative> DeleteFdpDerivative(FdpDerivative derivativeToDelete);
        Task<FdpDerivative> GetFdpDerivative(DerivativeFilter filter);
        Task<PagedResults<FdpDerivative>> ListFdpDerivatives(DerivativeFilter filter);
        Task<BmcMapping> GetMappedBmc(DerivativeFilter filter);

        Task<FdpDerivativeMapping> DeleteFdpDerivativeMapping(FdpDerivativeMapping fdpDerivativeMapping);
        Task<FdpDerivativeMapping> GetFdpDerivativeMapping(DerivativeMappingFilter filter);
        Task<PagedResults<FdpDerivativeMapping>> ListFdpDerivativeMappings(DerivativeMappingFilter filter);

        Task<FdpDerivativeMapping> CopyFdpDerivativeMappingToDocument(FdpDerivativeMapping fdpDerivativeMapping, int targetDocumentId);
        Task<IEnumerable<FdpDerivativeMapping>> CopyFdpDerivativeMappingsToDocument(int sourceDocumentId, int targetDocumentId);

        // Features and mappings

        Task<FdpFeature> DeleteFdpFeature(FdpFeature featureToDelete);
        Task<FdpFeature> GetFdpFeature(FeatureFilter filter);
        Task<PagedResults<FdpFeature>> ListFdpFeatures(FeatureFilter filter);

        Task<FdpFeatureMapping> DeleteFdpFeatureMapping(FdpFeatureMapping fdpFeatureMapping);
        Task<FdpFeatureMapping> GetFdpFeatureMapping(FeatureMappingFilter filter);
        Task<PagedResults<FdpFeatureMapping>> ListFdpFeatureMappings(FeatureMappingFilter filter);

        Task<FdpFeatureMapping> CopyFdpFeatureMappingToDocument(FdpFeatureMapping fdpFeatureMapping, int targetDocumentId);
        Task<IEnumerable<FdpFeatureMapping>> CopyFdpFeatureMappingsToDocument(int sourceDocumentId, int targetDocumentId);

        Task<FdpSpecialFeatureMapping> DeleteFdpSpecialFeatureMapping(FdpSpecialFeatureMapping fdpSpecialFeatureMapping);
        Task<FdpSpecialFeatureMapping> GetFdpSpecialFeatureMapping(SpecialFeatureMappingFilter filter);
        Task<PagedResults<FdpSpecialFeatureMapping>> ListFdpSpecialFeatureMappings(SpecialFeatureMappingFilter filter);

        Task<FdpSpecialFeatureMapping> CopyFdpSpecialFeatureMappingToDocument(FdpSpecialFeatureMapping fdpSpecialFeatureMapping, int targetDocumentId);
        Task<IEnumerable<FdpSpecialFeatureMapping>> CopyFdpSpecialFeatureMappingsToDocument(int sourceDocumentId, int targetDocumentId);

        // Trim and mappings

        Task<FdpTrim> DeleteFdpTrim(FdpTrim trimToDelete);
        Task<FdpTrim> GetFdpTrim(TrimFilter filter);
        Task<PagedResults<FdpTrim>> ListFdpTrims(TrimFilter filter);

        Task<FdpTrimMapping> DeleteFdpTrimMapping(FdpTrimMapping fdpTrimMapping);
        Task<FdpTrimMapping> GetFdpTrimMapping(TrimMappingFilter filter);
        Task<PagedResults<FdpTrimMapping>> ListFdpTrimMappings(TrimMappingFilter filter);

        Task<FdpTrimMapping> CopyFdpTrimMappingToDocument(FdpTrimMapping fdpTrimMapping, int targetDocumentId);
        Task<IEnumerable<FdpTrimMapping>> CopyFdpTrimMappingsToDocument(int sourceDocumentId, int targetDocumentId);

        Task<PagedResults<OxoDerivative>> ListOxoDerivatives(DerivativeMappingFilter filter);

        Task<OxoDerivative> UpdateBrochureModelCode(OxoDerivative derivative);
    }
}
