using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class TakeRateDataContext : BaseDataContext, ITakeRateDataContext
    {
        public TakeRateDataContext(string cdsId) : base(cdsId)
        {
            _documentDataStore = new OXODocDataStore(cdsId);
            _volumeDataStore = new FdpVolumeDataStore(cdsId);
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
                _volumeDataStore.FdpOxoDocSave(fdpOxoDoc);
            }
        }
        public TakeRateSummary GetVolumeHeader(TakeRateDataFilter filter)
        {
            return filter.FdpVolumeHeaderId.GetValueOrDefault() == 0 ?
                new EmptyVolumeHeader() : _volumeDataStore.FdpVolumeHeaderGet(filter.FdpVolumeHeaderId.Value);
        }
        public async Task<PagedResults<TakeRateSummary>> ListLatestTakeRateData()
        {
            var takeRates = await ListTakeRateData(new TakeRateFilter());

            takeRates.CurrentPage = takeRates.CurrentPage.Take(2);

            return takeRates;
        }
        public async Task<PagedResults<TakeRateSummary>> ListTakeRateData(TakeRateFilter filter)
        {
            return await Task.FromResult(_volumeDataStore.FdpVolumeHeaderGetManyByUsername(filter));
        }
        public void SaveVolumeHeader(FdpVolumeHeader header)
        {
            _volumeDataStore.FdpVolumeHeaderSave(header);
        }
        public OXODoc GetOxoDocument(VolumeFilter filter)
        {
            if (!filter.ProgrammeId.HasValue || filter.OxoDocId.GetValueOrDefault() == 0)
                return new EmptyOxoDocument();

            return _documentDataStore.OXODocGet(filter.OxoDocId.Value, filter.ProgrammeId.Value);
        }
        public async Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses()
        {
            return await Task.FromResult(_volumeDataStore.FdpTakeRateStatusGetMany());
        }
        public IEnumerable<OXODoc> ListAvailableOxoDocuments(VehicleFilter filter)
        {
            return _documentDataStore
                        .OXODocGetManyByUser(CDSID)
                        .Where(d => IsDocumentForVehicle(d, VehicleFilter.ToVehicle(filter)))
                        .Distinct(new OXODocComparer());
        }
        public async Task<TakeRateData> ListVolumeData(TakeRateDataFilter filter)
        {
            return !IsFilterValidForVolumeData(filter) ? 
                new TakeRateData() : await Task.FromResult(_volumeDataStore.FdpOxoVolumeDataItemList(filter));
        }

        public FdpOxoVolumeDataItem GetData(FdpOxoVolumeDataItem forData)
        {
            if (!forData.FdpOxoVolumeDataItemId.HasValue)
                return null;
            
            var dataItem = _volumeDataStore.FdpOxoVolumeDataItemGet(forData.FdpOxoVolumeDataItemId.Value);
            dataItem.History = _volumeDataStore.FdpOxoVolumeDataItemHistoryGetMany(forData.FdpOxoVolumeDataItemId.Value);
            dataItem.Notes = _volumeDataStore.FdpOxoVolumeDataItemNoteGetMany(forData.FdpOxoVolumeDataItemId.Value).ToList();

            return dataItem;
        }
        public IEnumerable<SpecialFeature> ListSpecialFeatures(ProgrammeFilter programmeFilter)
        {
            return _volumeDataStore.FdpSpecialFeatureTypeGetMany();
        }
        public void SaveData(FdpOxoVolumeDataItem dataItemToSave)
        {
            _volumeDataStore.FdpOxoVolumeDataItemSave(dataItemToSave);

            foreach (var note in dataItemToSave.Notes.Where(note => !note.FdpOxoVolumeDataItemNoteId.HasValue))
            {
                _volumeDataStore.FdpOxoVolumeDataItemNoteSave(note, dataItemToSave);
            }
        }
        public IEnumerable<FdpOxoVolumeDataItemHistory> ListHistory(FdpOxoVolumeDataItem forData)
        {
            throw new System.NotImplementedException();
        }
        public IEnumerable<FdpOxoVolumeDataItemNote> ListNotes(FdpOxoVolumeDataItem forData)
        {
            throw new System.NotImplementedException();
        }
        private static bool IsDocumentForVehicle(OXODoc documentToCheck, IVehicle vehicle)
        {
            return (!vehicle.ProgrammeId.HasValue || documentToCheck.ProgrammeId == vehicle.ProgrammeId.Value) &&
                (string.IsNullOrEmpty(vehicle.Gateway) || documentToCheck.Gateway == vehicle.Gateway);
        }
        private static bool IsFilterValidForVolumeData(ProgrammeFilter filter)
        {
            return filter != null && filter.OxoDocId.HasValue;
        }

        private OXODocDataStore _documentDataStore;
        private FdpVolumeDataStore _volumeDataStore;
    }
}
