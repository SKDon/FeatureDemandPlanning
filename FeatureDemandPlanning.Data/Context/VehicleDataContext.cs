using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class VehicleDataContext : BaseDataContext, IVehicleDataContext
    {
        public VehicleDataContext(string cdsId) : base(cdsId)
        {
            _vehicleDataStore = new VehicleDataStore(cdsId);
            _documentDataStore = new OXODocDataStore(cdsId);
            _programmeDataStore = new ProgrammeDataStore(cdsId);
            _volumeDataStore = new TakeRateDataStore(cdsId);
            _modelDataStore = new ModelDataStore(cdsId);
            _marketDataStore = new MarketDataStore(cdsId);
            _marketGroupDataStore = new MarketGroupDataStore(cdsId);
            _bodyDataStore = new ModelBodyDataStore(cdsId);
            _trimDataStore = new ModelTrimDataStore(cdsId);
            _engineDataStore = new ModelEngineDataStore(cdsId);
            _transmissionDataStore = new ModelTransmissionDataStore(cdsId);
            _vehicleDataStore = new VehicleDataStore(cdsId);
            _featureDataStore = new FeatureDataStore(cdsId);
            _derivativeDataStore = new DerivativeDataStore(cdsId);
        }
        public async Task<IVehicle> GetVehicle(VehicleFilter filter)
        {
            IVehicle vehicle = new EmptyVehicle();

            if (string.IsNullOrEmpty(filter.Code) && !filter.ProgrammeId.HasValue)
            {
                return vehicle;
            }
                
            var programme = _programmeDataStore.ProgrammeGetConfiguration(filter.ProgrammeId.Value);
            if (programme == null)
                return vehicle;

            vehicle = HydrateVehicleFromProgramme(programme);

            if (filter.Deep)
            {
                var availableDocuments = await ListAvailableOxoDocuments(filter);
                var availableImports = await ListAvailableImports(filter, programme);
                
                var availableMarketGroups = await ListAvailableMarketGroups(filter, programme);
                
                vehicle.AvailableDocuments = availableDocuments;
                vehicle.AvailableImports = availableImports;
                
                vehicle.AvailableMarketGroups = availableMarketGroups;
            }
            var availableModels = await ListAvailableModels(filter);
            vehicle.AvailableModels = availableModels;
            vehicle.Gateway = !string.IsNullOrEmpty(filter.Gateway) ? filter.Gateway : vehicle.Gateway;
            vehicle.ModelYear = !string.IsNullOrEmpty(filter.ModelYear) ? filter.ModelYear : vehicle.ModelYear;

            return vehicle;
        }
        public async Task<IVehicle> GetVehicle(ProgrammeFilter filter)
        {
            var vehicleFilter = new VehicleFilter()
            {
                ProgrammeId = filter.ProgrammeId,
                Code = filter.Code
            };
            return await GetVehicle(vehicleFilter);
        }
        public async Task<IEnumerable<OXODoc>> ListAvailableOxoDocuments(VehicleFilter filter)
        {
            return await Task.FromResult(_documentDataStore
                        .OXODocGetManyByUser(this.CDSID)
                        .Where(d => IsDocumentForVehicle(d, VehicleFilter.ToVehicle(filter)))
                        .Distinct(new OXODocComparer()));
        }
        public async Task<IEnumerable<TakeRateSummary>> ListAvailableImports(VehicleFilter filter, Programme forProgramme)
        {
            var imports = await Task.FromResult(_volumeDataStore
                            .FdpTakeRateHeaderGetManyByUsername(new TakeRateFilter()
                            {
                                ProgrammeId = filter.ProgrammeId,
                                Gateway = filter.Gateway
                            })
                            .CurrentPage
                            .ToList());

            foreach (var import in imports) {
                //import.Vehicle = (Vehicle)HydrateVehicleFromProgramme(forProgramme);
                //import.Vehicle.Gateway = import.Gateway;
            }

            return imports;
        }

        public async Task<IEnumerable<FdpModel>> ListAvailableModels(ProgrammeFilter filter)
        {
            var models = await Task.FromResult(_modelDataStore
                            .ModelGetMany(filter)
                            .ToList());

            return models;
        }
        public async Task<IEnumerable<MarketGroup>> ListAvailableMarketGroups(VehicleFilter filter, Programme forProgramme)
        {
            var marketGroups = Enumerable.Empty<MarketGroup>();
            if (filter.DocumentId.HasValue) {
                marketGroups =  await Task.FromResult(_marketGroupDataStore
                                   .MarketGroupGetMany(forProgramme.Id, filter.DocumentId.Value, true));
            } else {
                marketGroups = await Task.FromResult(_marketGroupDataStore
                                   .MarketGroupGetMany(true));
            }
            return marketGroups;
        }
        public async Task<IEnumerable<string>> ListAvailableMakes()
        {
            var programmes = await Task.FromResult(_programmeDataStore.ProgrammeGetMany());
            if (programmes == null || !programmes.Any())
            {
                return Enumerable.Empty<string>();
            }

            return programmes.Select(p => p.VehicleMake).Distinct().OrderBy(p => p);
        }

        public IEnumerable<ModelBody> ListBodies(ProgrammeFilter filter)
        {
            return _bodyDataStore.ModelBodyGetMany(filter);
        }
        public IEnumerable<Derivative> ListDerivatives(DerivativeFilter filter)
        {
            var derivatives =_derivativeDataStore.DerivativeGetMany(filter);

            var listDerivatives = derivatives as IList<Derivative> ?? derivatives.ToList();
            // Eliminate the derivatives with no BMC as this will cause real issues
            if (derivatives != null && listDerivatives.Any())
            {
                listDerivatives = listDerivatives.Where(d => !string.IsNullOrEmpty(d.DerivativeCode)).ToList();
            }
            foreach (var derivative in listDerivatives)
            {
                
                    if (derivative.BodyId.HasValue)
                        derivative.Body = _bodyDataStore.ModelBodyGet(derivative.BodyId.Value, filter.DocumentId);

                    if (derivative.EngineId.HasValue)
                        derivative.Engine = _engineDataStore.ModelEngineGet(derivative.EngineId.Value, filter.DocumentId);

                    if (derivative.TransmissionId.HasValue)
                        derivative.Transmission =
                            _transmissionDataStore.ModelTransmissionGet(derivative.TransmissionId.Value, filter.DocumentId);
                
            }
            return listDerivatives;
        }
        public IEnumerable<Gateway> ListGateways(ProgrammeFilter filter)
        {
            return _documentDataStore.GatewayGetMany().Where(g => string.IsNullOrEmpty(filter.Code) || g.VehicleName == filter.Code);
        }
        public IEnumerable<OXODoc> ListPublishedDocuments(ProgrammeFilter filter)
        {
            return _documentDataStore.FdpOxoDocumentsGetMany(filter);
        }
        public IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter)
        {
            return _transmissionDataStore.ModelTransmissionGetMany(filter);   
        }
        public IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter)
        {
            return _engineDataStore.ModelEngineGetMany(filter);
        }
        public IEnumerable<FdpTrimMapping> ListTrim(TrimFilter filter)
        {
            return _trimDataStore.ModelTrimGetMany(filter);
        }
        public IEnumerable<FdpTrimMapping> ListOxoTrim(TrimFilter filter)
        {
            filter.PageSize = 0;
            return _trimDataStore.ModelTrimOxoTrimGetMany(filter);
        }
        public async Task<IEnumerable<Feature>> ListFeatures(ProgrammeFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FeatureGetMany("fdp", paramId: filter.VehicleId.Value));
        }
        public async Task<IEnumerable<FdpFeature>> ListFeatures(FeatureFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FeatureGetManyByDocumentId(filter));
        }
        public IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter)
        {
            var groups = _featureDataStore.FeatureGroupGetMany().ToList();
            groups.Add(new FeatureGroup() { FeatureGroupName = "OPTION PACKS" });
            return groups;
        }
        public EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping)
        {
            return _programmeDataStore.EngineCodeMappingSave(mapping);
        }
        public Programme GetProgramme(ProgrammeFilter filter)
        {
            var programmes = ListProgrammes(filter);
            if (!programmes.Any())
                return new EmptyProgramme();

            return programmes.First();
        }
        public IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter)
        {
            var programmes = _programmeDataStore.ProgrammeByGatewayGetMany();
            if (programmes == null || !programmes.Any())
                return Enumerable.Empty<Programme>();

            programmes = programmes
                .Where(p => !filter.ProgrammeId.HasValue || p.Id == filter.ProgrammeId.Value)
                .Where(p => !filter.VehicleId.HasValue || p.VehicleId == filter.VehicleId.Value)
                .Where(p => string.IsNullOrEmpty(filter.Code) || p.VehicleName.Equals(filter.Code, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => string.IsNullOrEmpty(filter.Make) || p.VehicleMake.Equals(filter.Make, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => string.IsNullOrEmpty(filter.ModelYear) || p.ModelYear.Equals(filter.ModelYear, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => string.IsNullOrEmpty(filter.Gateway) || p.Gateway.Equals(filter.Gateway, StringComparison.InvariantCultureIgnoreCase))
                .Select(p => p);

            return programmes;
        }

        // Derivatives and mappings
        
        public async Task<FdpDerivative> DeleteFdpDerivative(FdpDerivative derivativeToDelete)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeDelete(derivativeToDelete));
        }
        public async Task<FdpDerivative> GetFdpDerivative(DerivativeFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeGet(filter));
        }
        public async Task<PagedResults<FdpDerivative>> ListFdpDerivatives(DerivativeFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeGetMany(filter));
        }
        public async Task<FdpDerivativeMapping> DeleteFdpDerivativeMapping(FdpDerivativeMapping derivativeMappingToDelete)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingDelete(derivativeMappingToDelete));
        }
        public async Task<FdpDerivativeMapping> GetFdpDerivativeMapping(DerivativeMappingFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingGet(filter));
        }
        public async Task<PagedResults<FdpDerivativeMapping>> ListFdpDerivativeMappings(DerivativeMappingFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingGetMany(filter));
        }
        public async Task<PagedResults<OxoDerivative>> ListOxoDerivatives(DerivativeMappingFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.FdpOxoDerivativeGetMany(filter));
        }
        public async Task<FdpDerivativeMapping> CopyFdpDerivativeMappingToDocument(FdpDerivativeMapping fdpDerivativeMapping, int targetDocumentId)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingCopy(fdpDerivativeMapping, targetDocumentId));
        }
        public async Task<IEnumerable<FdpDerivativeMapping>> CopyFdpDerivativeMappingsToDocument(int sourceDocumentId, int targetDocumentId)
        {
            return await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingsCopy(sourceDocumentId, targetDocumentId));
        }
        public async Task<BmcMapping> GetMappedBmc(DerivativeFilter filter)
        {
            return await Task.FromResult(_derivativeDataStore.GetMappedBmc(filter));
        }

        // Features and mappings

        public async Task<FdpFeature> DeleteFdpFeature(FdpFeature featureToDelete)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureDelete(featureToDelete));
        }
        public async Task<FdpFeature> GetFdpFeature(FeatureFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureGet(filter));
        }
        public async Task<PagedResults<FdpFeature>> ListFdpFeatures(FeatureFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureGetMany(filter));
        }
        public async Task<FdpFeatureMapping> DeleteFdpFeatureMapping(FdpFeatureMapping featureMappingToDelete)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureMappingDelete(featureMappingToDelete));
        }
        public async Task<FdpFeatureMapping> GetFdpFeatureMapping(FeatureMappingFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureMappingGet(filter));
        }
        public async Task<PagedResults<FdpFeatureMapping>> ListFdpFeatureMappings(FeatureMappingFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureMappingGetMany(filter));
        }
        public async Task<FdpFeatureMapping> CopyFdpFeatureMappingToDocument(FdpFeatureMapping fdpFeatureMapping, int targetDocumentId)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureMappingCopy(fdpFeatureMapping, targetDocumentId));
        }
        public async Task<IEnumerable<FdpFeatureMapping>> CopyFdpFeatureMappingsToDocument(int sourceDocumentId, int targetDocumentId)
        {
            return await Task.FromResult(_featureDataStore.FdpFeatureMappingsCopy(sourceDocumentId, targetDocumentId));
        }
        public async Task<FdpSpecialFeatureMapping> DeleteFdpSpecialFeatureMapping(FdpSpecialFeatureMapping featureMappingToDelete)
        {
            return await Task.FromResult(_featureDataStore.FdpSpecialFeatureMappingDelete(featureMappingToDelete));
        }
        public async Task<FdpSpecialFeatureMapping> GetFdpSpecialFeatureMapping(SpecialFeatureMappingFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpSpecialFeatureMappingGet(filter));
        }
        public async Task<PagedResults<FdpSpecialFeatureMapping>> ListFdpSpecialFeatureMappings(SpecialFeatureMappingFilter filter)
        {
            return await Task.FromResult(_featureDataStore.FdpSpecialFeatureMappingGetMany(filter));
        }
        public async Task<FdpSpecialFeatureMapping> CopyFdpSpecialFeatureMappingToDocument(FdpSpecialFeatureMapping fdpSpecialFeatureMapping, int targetDocumentId)
        {
            return await Task.FromResult(_featureDataStore.FdpSpecialFeatureMappingCopy(fdpSpecialFeatureMapping, targetDocumentId));
        }
        public Task<IEnumerable<FdpSpecialFeatureMapping>> CopyFdpSpecialFeatureMappingsToDocument(int sourceDocumentId, int targetDocumentId)
        {
            throw new NotImplementedException();
        }
        public async Task<PagedResults<OxoFeature>> ListOxoFeatures(FeatureMappingFilter filter)
        {
            filter.IncludeAllFeatures = true;
            filter.OxoFeaturesOnly = true;
            return await Task.FromResult(_featureDataStore.FdpOxoFeatureGetMany(filter));
        }

        // Trim and mappings

        public async Task<FdpTrim> DeleteFdpTrim(FdpTrim trimToDelete)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimDelete(trimToDelete));
        }
        public async Task<FdpTrim> GetFdpTrim(TrimFilter filter)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimGet(filter));
        }
        public async Task<PagedResults<FdpTrim>> ListFdpTrims(TrimFilter filter)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimGetMany(filter));
        }
        public async Task<FdpTrimMapping> DeleteFdpTrimMapping(FdpTrimMapping trimMappingToDelete)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimMappingDelete(trimMappingToDelete));
        }
        public async Task<FdpTrimMapping> GetFdpTrimMapping(TrimMappingFilter filter)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimMappingGet(filter));
        }
        public async Task<PagedResults<FdpTrimMapping>> ListFdpTrimMappings(TrimMappingFilter filter)
        {
            return await Task.FromResult(_trimDataStore.FdpTrimMappingGetMany(filter));
        }
        public Task<FdpTrimMapping> CopyFdpTrimMappingToDocument(FdpTrimMapping fdpTrimMapping, int targetDocumentId)
        {
            throw new NotImplementedException();
        }
        public Task<IEnumerable<FdpTrimMapping>> CopyFdpTrimMappingsToDocument(int sourceDocumentId, int targetDocumentId)
        {
            throw new NotImplementedException();
        }
        public IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter)
        {
            var programmes = ListProgrammes(filter);
            if (programmes == null || !programmes.Any())
                return Enumerable.Empty<IVehicle>();

            return programmes.Select(p => HydrateVehicleFromProgramme(p, filter.VehicleIndex));
        }
        public IEnumerable<TrimLevel> ListTrimLevels(ProgrammeFilter programmeFilter)
        {
            for (var i = 1; i <= 10; i++)
            {
                yield return new TrimLevel() {
                    Level = i,
                    DisplayOrder = i,
                    Description = string.Format("TL{0}", i)
                };
            }
        }
        public async Task<OxoDerivative> UpdateBrochureModelCode(OxoDerivative derivative)
        {
            return await Task.FromResult(_derivativeDataStore.BrochureModelCodeUpdate(derivative));
        }
        public async Task<PagedResults<OxoTrim>> ListOxoTrim(TrimMappingFilter filter)
        {
            filter.IncludeAllTrim = true;
            filter.OxoTrimOnly = true;
            filter.PageSize = 0;
            return await Task.FromResult(_trimDataStore.FdpOxoTrimGetMany(filter));
        }
        public async Task<OxoTrim> UpdateDpckCode(OxoTrim trim)
        {
            return await Task.FromResult(_trimDataStore.DpckUpdate(trim));
        }
        public async Task<OxoFeature> UpdateFeatureCode(OxoFeature fdpFeature)
        {
            return await Task.FromResult(_featureDataStore.FeatureCodeUpdate(fdpFeature));
        }

        #region "Private Methods"

        private IVehicle HydrateVehicleFromProgramme(Programme programme)
        {
            return HydrateVehicleFromProgramme(programme, null);
        }

        private IVehicle HydrateVehicleFromProgramme(Programme programme, int? vehicleIndex)
        {
            if (programme == null)
                return new EmptyVehicle();

            return new Vehicle()
            {
                Make = programme.VehicleMake,
                Code = programme.VehicleName,
                ProgrammeId = programme.Id,
                ModelYear = programme.ModelYear,
                Gateway = vehicleIndex.GetValueOrDefault() == 0 ? programme.Gateway : string.Empty,
                Description = string.Format("{0} - {1}", programme.VehicleName, programme.VehicleAKA),
                Programmes = new List<Programme>() { programme }
            };
        }

        private bool IsDocumentForVehicle(OXODoc documentToCheck, IVehicle vehicle)
        {
            return (!vehicle.ProgrammeId.HasValue || documentToCheck.ProgrammeId == vehicle.ProgrammeId.Value) &&
                (string.IsNullOrEmpty(vehicle.Gateway) || documentToCheck.Gateway == vehicle.Gateway);
        }

        #endregion

        #region "Private Members"

        private VehicleDataStore _vehicleDataStore = null;
        private ProgrammeDataStore _programmeDataStore = null;
        private OXODocDataStore _documentDataStore = null;
        private TakeRateDataStore _volumeDataStore = null;
        private ModelDataStore _modelDataStore = null;
        private MarketDataStore _marketDataStore = null;
        private MarketGroupDataStore _marketGroupDataStore = null;
        private ModelBodyDataStore _bodyDataStore = null;
        private ModelTransmissionDataStore _transmissionDataStore = null;
        private ModelTrimDataStore _trimDataStore = null;
        private ModelEngineDataStore _engineDataStore = null;
        private FeatureDataStore _featureDataStore = null;
        private DerivativeDataStore _derivativeDataStore = null;

        #endregion

    }
}
