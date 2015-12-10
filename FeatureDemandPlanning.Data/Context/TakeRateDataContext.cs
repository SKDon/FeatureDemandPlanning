using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class TakeRateDataContext : BaseDataContext, ITakeRateDataContext
    {
        public TakeRateDataContext(string cdsId) : base(cdsId)
        {
            _vehicleDataStore = new VehicleDataStore(cdsId);
            _documentDataStore = new OXODocDataStore(cdsId);
            _takeRateDataStore = new TakeRateDataStore(cdsId);
            _modelDataStore = new ModelDataStore(cdsId);
        }
        public IVolume GetVolume(TakeRateFilter filter)
        {
            return Volume.FromFilter(filter);
        }
        public IVolume GetVolume(VolumeFilter filter)
        {
            return Volume.FromFilter(filter);
        }
        public void ProcessMappedData(IVolume volumeToProcess)
        {

        }
        public void SaveVolume(IVolume volumeToSave)
        {
            foreach(var header in volumeToSave.VolumeSummary) {

                var fdpOxoDoc = new FdpOxoDoc() {
                    Header = header,
                    Document = volumeToSave.Document
                };
                _takeRateDataStore.FdpOxoDocSave(fdpOxoDoc);
            }
        }
        public TakeRateSummary GetVolumeHeader(VolumeFilter filter)
        {
            if (filter.FdpVolumeHeaderId.GetValueOrDefault() == 0)
                return new EmptyVolumeHeader();

            return _takeRateDataStore.FdpVolumeHeaderGet(filter.FdpVolumeHeaderId.Value);
        }
        public async Task<PagedResults<TakeRateSummary>> ListLatestTakeRateData()
        {
            var takeRates = await ListTakeRateData(new TakeRateFilter());

            takeRates.CurrentPage = takeRates.CurrentPage.Take(2);

            return takeRates;
        }
        public async Task<PagedResults<TakeRateSummary>> ListTakeRateData(TakeRateFilter filter)
        {
            return await Task.FromResult<PagedResults<TakeRateSummary>>(
                _takeRateDataStore.FdpVolumeHeaderGetManyByUsername(filter));
        }
        public void SaveVolumeHeader(FdpVolumeHeader header)
        {
            _takeRateDataStore.FdpVolumeHeaderSave(header);
        }
        public OXODoc GetOxoDocument(VolumeFilter filter)
        {
            if (!filter.ProgrammeId.HasValue || filter.OxoDocId.GetValueOrDefault() == 0)
                return new EmptyOxoDocument();

            return _documentDataStore.OXODocGet(filter.OxoDocId.Value, filter.ProgrammeId.Value);
        }
        public async Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses()
        {
            return await Task.FromResult<IEnumerable<TakeRateStatus>>(_takeRateDataStore.FdpTakeRateStatusGetMany());
        }
        public IEnumerable<OXODoc> ListAvailableOxoDocuments(VehicleFilter filter)
        {
            return _documentDataStore
                        .OXODocGetManyByUser(this.CDSID)
                        .Where(d => IsDocumentForVehicle(d, VehicleFilter.ToVehicle(filter)))
                        .Distinct(new OXODocComparer());
        }
        public TakeRateData ListVolumeData(VolumeFilter filter) 
        {
            if (!IsFilterValidForVolumeData(filter))
                return new TakeRateData();

            return _takeRateDataStore.TakeRateDataItemList(filter);
        }
        public TakeRateDataItem GetDataItem(TakeRateFilter filter)
        {
            return _takeRateDataStore.TakeRateDataItemGet(filter);
        }
        public IEnumerable<SpecialFeature> ListSpecialFeatures(ProgrammeFilter programmeFilter)
        {
            return _takeRateDataStore.FdpSpecialFeatureTypeGetMany();
        }
        public void SaveData(TakeRateDataItem dataItemToSave)
        {
            _takeRateDataStore.TakeRateDataItemSave(dataItemToSave);
        }
        public async Task<IEnumerable<TakeRateDataItem>> SaveChangeset(TakeRateParameters parameters)
        {
            var results = new List<TakeRateDataItem>();
            foreach (var change in parameters.Changes)
            {
                var result = await Task.FromResult(_takeRateDataStore.TakeRateDataItemSave(change.ToDataItem()));
                results.Add(result);
            }
            return results;
        }
        public IEnumerable<FdpOxoVolumeDataItemHistory> ListHistory(TakeRateDataItem forData)
        {
            throw new System.NotImplementedException();
        }
        public IEnumerable<TakeRateDataItemNote> ListNotes(TakeRateDataItem forData)
        {
            throw new System.NotImplementedException();
        }
        private bool IsDocumentForVehicle(OXODoc documentToCheck, IVehicle vehicle)
        {
            return (!vehicle.ProgrammeId.HasValue || documentToCheck.ProgrammeId == vehicle.ProgrammeId.Value) &&
                (string.IsNullOrEmpty(vehicle.Gateway) || documentToCheck.Gateway == vehicle.Gateway);
        }
        private bool IsFilterValidForVolumeData(VolumeFilter filter)
        {
            //return filter.OxoDocId.HasValue && (filter.MarketId.HasValue || filter.MarketGroupId.HasValue);
            return filter.OxoDocId.HasValue;
        }

        private VehicleDataStore _vehicleDataStore = null;
        private ModelDataStore _modelDataStore = null;
        private OXODocDataStore _documentDataStore = null;
        private TakeRateDataStore _takeRateDataStore = null;
    }
}
