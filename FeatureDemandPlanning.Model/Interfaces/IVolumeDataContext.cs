using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVolumeDataContext
    {
        TakeRateSummary GetVolumeHeader(VolumeFilter filter);
        Task<PagedResults<TakeRateSummary>> ListTakeRateData(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListLatestTakeRateData();
        void SaveVolumeHeader(FdpVolumeHeader headerToSave);
        
        IVolume GetVolume(VolumeFilter filter);
        void SaveVolume(IVolume volumeToSave);

        FdpOxoVolumeDataItem GetData(FdpOxoVolumeDataItem forData);
        VolumeData ListVolumeData(VolumeFilter filter);
        void SaveData(FdpOxoVolumeDataItem dataItemToSave);
        IEnumerable<FdpOxoVolumeDataItemHistory> ListHistory(FdpOxoVolumeDataItem forData);
        IEnumerable<FdpOxoVolumeDataItemNote> ListNotes(FdpOxoVolumeDataItem forData);

        OXODoc GetOxoDocument(VolumeFilter filter);
        IEnumerable<OXODoc> ListAvailableOxoDocuments(VehicleFilter filter);

        void ProcessMappedData(IVolume volumeToProcess);


        IEnumerable<SpecialFeature> ListSpecialFeatures(ProgrammeFilter programmeFilter);
    }
}