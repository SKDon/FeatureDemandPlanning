﻿using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Data;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface ITakeRateDataContext
    {
        Task<IEnumerable<MarketGroup>> ListAvailableMarketGroups(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListTakeRateDocuments(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListLatestTakeRateDocuments();
        Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses();
        
        Task<TakeRateSummary> GetTakeRateDocumentHeader(TakeRateFilter filter);
        Task<ITakeRateDocument> GetTakeRateDocument(TakeRateFilter filter);
        
        Task<TakeRateData> GetTakeRateDocumentData(TakeRateFilter filter);
        Task<TakeRateData> GetTakeRateDocumentFeatures(TakeRateFilter filter);

        Task<TakeRateDataItem> GetDataItem(TakeRateFilter filter);
        Task<IEnumerable<TakeRateDataItemNote>> ListDataItemNotes(TakeRateFilter filter);

        Task<TakeRateDocumentHeader> SaveTakeRateDocumentHeader(TakeRateDocumentHeader headerToSave);
        Task<TakeRateDataItem> SaveDataItem(TakeRateDataItem dataItemToSave);

        Task<OXODoc> GetUnderlyingOxoDocument(TakeRateFilter filter);
        Task<IEnumerable<SpecialFeature>> ListSpecialFeatures(ProgrammeFilter programmeFilter);

        Task<IEnumerable<TakeRateDataItem>> CalculateTakeRateAndVolumeByMarket(TakeRateFilter filter, DataChange forChange);

        Task<FdpChangeset> GetUnsavedChangesForUser(TakeRateFilter filter);
        Task<FdpChangeset> SaveChangeset(TakeRateFilter filter, FdpChangeset changesetToSave);

        Task<FdpChangeset> PersistChangeset(TakeRateFilter takeRateFilter);
        Task<FdpChangeset> UndoChangeset(TakeRateFilter takeRateFilter);
        Task<FdpChangeset> UndoAllChangeset(TakeRateFilter takeRateFilter);
        Task<FdpChangeset> RevertUnsavedChangesForUser(TakeRateFilter takeRateFilter);

        Task<int> GetVolumeForModel(TakeRateFilter filter);
        Task<int> GetVolumeForMarket(TakeRateFilter filter);

        Task<FdpChangesetHistory> GetChangesetHistory(TakeRateFilter filter);

        Task<DataChange> AddDataItemNote(TakeRateFilter filter);

        Task<FdpValidation> GetValidation(TakeRateFilter filter);

        Task<Programme> GetProgramme(TakeRateFilter takeRateFilter);

        Task<MarketReview> GetMarketReview(TakeRateFilter filter);
        Task<PagedResults<MarketReview>> ListMarketReview(TakeRateFilter filter);
        Task<MarketReview> SetMarketReview(TakeRateFilter filter);

        Task<RawTakeRateData> GetRawData(TakeRateFilter filter);

        IEnumerable<ValidationResult> PersistValidationErrors(TakeRateFilter filter, FluentValidation.Results.ValidationResult validationResult, bool global = false);

        Task<TakeRateSummary> CloneTakeRateDocument(TakeRateFilter filter);

        Task<IEnumerable<RawPowertrainDataItem>> ListPowertrainData(TakeRateFilter takeRateFilter);

        void IgnoreValidationError(TakeRateFilter takeRateFilter);

        Task<FdpChangesetHistoryDetails> GetChangesetHistoryDetails(TakeRateFilter filter);

        Task<PagedResults<Publish>> ListPublish(TakeRateFilter filter);

        Task<Publish> SetPublish(TakeRateFilter takeRateFilter);

        Task<Publish> GetPublish(TakeRateFilter takeRateFilter);

        Task<DataTable> GetChangesetHistoryDetailsAsDataTable(TakeRateFilter filter);
    }
}