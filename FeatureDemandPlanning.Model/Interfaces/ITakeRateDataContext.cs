using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface ITakeRateDataContext
    {
        TakeRateSummary GetVolumeHeader(TakeRateDataFilter filter);
        Task<PagedResults<TakeRateSummary>> ListTakeRateData(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListLatestTakeRateData();
        Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses();

        void SaveVolumeHeader(FdpVolumeHeader headerToSave);
        
        //IVolume GetVolume(TakeRateDataFilter filter);
        void SaveVolume(IVolume volumeToSave);

        FdpOxoVolumeDataItem GetData(FdpOxoVolumeDataItem forData);
        Task<TakeRateData> ListVolumeData(TakeRateDataFilter filter);
        void SaveData(FdpOxoVolumeDataItem dataItemToSave);
        IEnumerable<FdpOxoVolumeDataItemHistory> ListHistory(FdpOxoVolumeDataItem forData);
        IEnumerable<FdpOxoVolumeDataItemNote> ListNotes(FdpOxoVolumeDataItem forData);

        OXODoc GetOxoDocument(VolumeFilter filter);
        IEnumerable<OXODoc> ListAvailableOxoDocuments(VehicleFilter filter);

        void ProcessMappedData(IVolume volumeToProcess);
        IEnumerable<SpecialFeature> ListSpecialFeatures(ProgrammeFilter programmeFilter);
    }
}