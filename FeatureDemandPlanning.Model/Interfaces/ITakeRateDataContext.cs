using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface ITakeRateDataContext
    {
        Task<PagedResults<TakeRateSummary>> ListTakeRateDocuments(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListLatestTakeRateDocuments();
        Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses();
        
        Task<TakeRateSummary> GetTakeRateDocumentHeader(TakeRateFilter filter);
        Task<ITakeRateDocument> GetTakeRateDocument(TakeRateFilter filter);
        
        Task<TakeRateData> GetTakeRateDocumentData(TakeRateFilter filter);

        Task<TakeRateDataItem> GetDataItem(TakeRateFilter filter);
        Task<IEnumerable<TakeRateDataItemNote>> ListDataItemNotes(TakeRateFilter filter);

        Task<TakeRateDocumentHeader> SaveTakeRateDocumentHeader(TakeRateDocumentHeader headerToSave);
        Task<ITakeRateDocument> SaveTakeRateDocument(ITakeRateDocument documentToSave);
        Task<TakeRateDataItem> SaveDataItem(TakeRateDataItem dataItemToSave);

        Task<ITakeRateDocument> ProcessMappedData(ITakeRateDocument documentToProcess);
        
        Task<OXODoc> GetUnderlyingOxoDocument(TakeRateFilter filter);
        Task<IEnumerable<SpecialFeature>> ListSpecialFeatures(ProgrammeFilter programmeFilter);

        Task<IEnumerable<TakeRateDataItem>> CalculateTakeRateAndVolumeByMarket(TakeRateFilter filter, DataChange forChange);

        Task<FdpChangeset> GetUnsavedChangesForUser(TakeRateFilter filter);
        Task<FdpChangeset> SaveChangeset(TakeRateFilter filter, FdpChangeset changesetToSave);
        Task<DataChange> SaveChangesetDataChange(TakeRateFilter filter, DataChange changeToSave);

        Task<FdpChangeset> PersistChangeset(TakeRateFilter takeRateFilter, FdpChangeset changesetToPersist);
        Task<DataChange> PersistChangesetDataChange(TakeRateFilter filter, DataChange changeToPersist);

        Task<FdpChangeset> RevertUnsavedChangesForUser(TakeRateFilter takeRateFilter);

        Task<int> GetVolumeForModel(TakeRateFilter filter);
        Task<int> GetVolumeForMarket(TakeRateFilter filter);
    }
}