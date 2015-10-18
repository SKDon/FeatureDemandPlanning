using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IVolumeDataContext
    {
        FdpVolumeHeader GetVolumeHeader(VolumeFilter filter);
        IEnumerable<FdpVolumeHeader> ListVolumeHeaders(VolumeFilter filter);
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
        
    }
}