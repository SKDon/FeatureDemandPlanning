using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class TakeRateDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public TakeRateDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }

        #endregion

        public ImportResult ImportData(string filePath)
        {
            throw new NotImplementedException();
        }

        public TakeRateDataItem TakeRateDataItemGet(TakeRateFilter filter)
        {
            TakeRateDataItem retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    
                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    para.Add("@MarketGroupId", filter.MarketGroupId, DbType.Int32);
                    para.Add("@ModelId", filter.ModelId, DbType.Int32);
                    para.Add("@FdpModelId", filter.FdpModelId, DbType.Int32);
                    para.Add("@FeatureId", filter.FeatureId, DbType.Int32);
                    para.Add("@FdpFeatureId", filter.FdpFeatureId, DbType.Int32);

                    var results = conn.QueryMultiple(fdpTakeRateDataItemGetStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    retVal = results.Read<TakeRateDataItem>().First();

                    retVal.Notes = results.Read<TakeRateDataItemNote>();
                    retVal.History = results.Read<TakeRateDataItemAudit>();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public TakeRateDataItem TakeRateModelSummaryItemGet(TakeRateFilter filter)
        {
            TakeRateDataItem retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    
                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    para.Add("@ModelId", filter.ModelId, DbType.Int32);
                    para.Add("@FdpModelId", filter.FdpModelId, DbType.Int32);

                    var results = conn.QueryMultiple(fdpTakeRateModelSummaryItemGetStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    retVal = results.Read<TakeRateDataItem>().First();

                    retVal.Notes = results.Read<TakeRateDataItemNote>();
                    retVal.History = results.Read<TakeRateDataItemAudit>();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public TakeRateData TakeRateDataItemList(TakeRateFilter filter)
        {
            var retVal = new TakeRateData();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var cmd = conn.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "Fdp_TakeRateData_GetCrossTab";
                    cmd.CommandTimeout = 0;

                    if (filter.DocumentId != null)
                        cmd.Parameters.Add(new SqlParameter("@DocumentId", SqlDbType.Int) { Value = filter.DocumentId.Value });
                    cmd.Parameters.Add(new SqlParameter("@ModelIds", SqlDbType.NVarChar, -1) { Value = filter.Models.ToCommaSeperatedString() });

                    if (filter.MarketGroupId.HasValue)
                    {
                        cmd.Parameters.Add(new SqlParameter("@Mode", SqlDbType.NVarChar, 2) { Value = "MG" });
                        cmd.Parameters.Add(new SqlParameter("@ObjectId", SqlDbType.Int) { Value = filter.MarketGroupId.Value });
                    }
                    else if (filter.MarketId.HasValue)
                    {
                        cmd.Parameters.Add(new SqlParameter("@Mode", SqlDbType.NVarChar, 2) { Value = "M" });
                        cmd.Parameters.Add(new SqlParameter("@ObjectId", SqlDbType.Int) { Value = filter.MarketId.Value });
                    }
                    else
                    {
                        cmd.Parameters.Add(new SqlParameter("@Mode", SqlDbType.NVarChar, 2) { Value = "MG" });
                    }

                    if (filter.Mode == TakeRateResultMode.PercentageTakeRate)
                    {
                        cmd.Parameters.Add(new SqlParameter("@ShowPercentage", SqlDbType.Bit) { Value = true });
                    }

                    var adapter = new SqlDataAdapter((SqlCommand)cmd);
                    var ds = new DataSet();
                    adapter.Fill(ds);

                    // 1. Take rate / volume data
                    retVal.RawData = ds.Tables[0].AsEnumerable();

                    // 2. Whether or not features are standard / optional or not applicable for derivative / market
                    retVal.FeatureApplicabilityData = ds.Tables[1].AsEnumerable();

                    // 3. Total volumes for each model by market
                    retVal.TakeRateSummaryByModel = ds.Tables[2].AsEnumerable().Select(d => new ModelTakeRateSummary
                    {
                        StringIdentifier = d.Field<string>("StringIdentifier"),
                        IsFdpModel = d.Field<bool>("IsFdpModel"),
                        Volume = d.Field<int>("Volume"),
                        PercentageOfFilteredVolume = d.Field<decimal>("PercentageOfFilteredVolume")
                    });

                    // 4. Summary information
                    var summary = ds.Tables[3].AsEnumerable().FirstOrDefault();
                    if (summary != null)
                    {
                        retVal.TotalVolume = summary.Field<int>("TotalVolume");
                        retVal.FilteredVolume = summary.Field<int>("FilteredVolume");
                        retVal.PercentageOfTotalVolume = summary.Field<decimal>("PercentageOfTotalVolume");
                        retVal.CreatedBy = summary.Field<string>("CreatedBy");
                        retVal.CreatedOn = summary.Field<DateTime>("CreatedOn");
                    }

                    // 5. Notes
                    retVal.NoteAvailability = ds.Tables[4].AsEnumerable().Select(n => new TakeRateDataItemNote
                    {
                        MarketId = n.Field<int?>("MarketId"),
                        MarketGroupId = n.Field<int?>("MarketGroupId"),
                        ModelId = n.Field<int?>("ModelId"),
                        FdpModelId = n.Field<int?>("FdpModelId"),
                        FeatureId = n.Field<int?>("FeatureId"),
                        FdpFeatureId = n.Field<int?>("FdpFeatureId")
                    });
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemList", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }

        public TakeRateDataItem TakeRateDataItemSave(TakeRateDataItem dataItemToSave)
        {
            TakeRateDataItem retVal = new EmptyTakeRateDataItem();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    int? takeRateDataItemId = null;
             
                    para.Add("@FdpTakeRateDataItemId", dataItemToSave.FdpTakeRateDataItemId, DbType.Int32, ParameterDirection.InputOutput);
                    para.Add("@DocumentId", dataItemToSave.DocumentId, DbType.Int32);
                    para.Add("@ModelId", dataItemToSave.ModelId, DbType.Int32);
                    para.Add("@FdpModelId", dataItemToSave.FdpModelId, DbType.Int32);
                    para.Add("@FeatureId", dataItemToSave.FeatureId, DbType.Int32);
                    para.Add("@FdpFeatureId", dataItemToSave.FdpFeatureId, DbType.Int32);
                    para.Add("@MarketGroupId", dataItemToSave.MarketGroupId, DbType.Int32);
                    para.Add("@MarketId", dataItemToSave.MarketId, DbType.Int32);
                    para.Add("@Volume", dataItemToSave.Volume, DbType.Int32);
                    para.Add("@PercentageTakeRate", dataItemToSave.PercentageTakeRate, DbType.Decimal);
                    para.Add("@FeaturePackId", dataItemToSave.FeaturePackId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);

                    var rows = conn.Execute(fdpTakeRateDataItemSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    if (rows > 0)
                    {
                        takeRateDataItemId = para.Get<int?>("@FdpTakeRateDataItemId");
                    }
                    
                    // Save any notes 
                    foreach (var note in dataItemToSave.Notes.Where(n => !n.FdpTakeRateDataItemNoteId.HasValue))
                    {
                        note.FdpTakeRateDataItemId = takeRateDataItemId;
                        TakeRateDataItemNoteSave(note);
                    }

                    retVal = TakeRateDataItemGet(new TakeRateFilter { TakeRateDataItemId = takeRateDataItemId });
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemSave", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }
        public TakeRateDataItemNote TakeRateDataItemNoteSave(TakeRateDataItemNote noteToSave)
        {
            TakeRateDataItemNote retVal = new EmptyTakeRateDataItemNote();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", noteToSave.FdpTakeRateDataItemId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);
                    para.Add("@Note", noteToSave.Note, DbType.String);
                    
                    var results = conn.Query<TakeRateDataItemNote>(fdpTakeRateDataItemNoteSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    var takeRateDataItemNotes = results as IList<TakeRateDataItemNote> ?? results.ToList();
                    if (takeRateDataItemNotes.Any())
                    {
                        retVal = takeRateDataItemNotes.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemNoteSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<TakeRateDataItemNote> TakeRateDataItemNoteGetMany(TakeRateFilter filter)
        {
            var retVal = Enumerable.Empty<TakeRateDataItemNote>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", filter.TakeRateDataItemId, DbType.Int32);

                    retVal = conn.Query<TakeRateDataItemNote>(fdpTakeRateDataItemNoteGetManyStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemNoteGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<TakeRateDataItemAudit> TakeRateDataItemHistoryGetMany(TakeRateFilter filter)
        {
            var retVal = Enumerable.Empty<TakeRateDataItemAudit>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", filter.TakeRateDataItemId, DbType.Int32);

                    retVal = conn.Query<TakeRateDataItemAudit>(fdpTakeRateDataItemHistoryGetManyStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemHistoryGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public TakeRateSummary TakeRateDocumentHeaderGet(TakeRateFilter filter)
        {
            var volumeHeaders = FdpTakeRateHeaderGetManyByUsername(filter);
            if (volumeHeaders == null || !volumeHeaders.CurrentPage.Any())
                return null;

            var summary = filter.TakeRateId.HasValue ? volumeHeaders.CurrentPage.FirstOrDefault(v => v.TakeRateId == filter.TakeRateId) : volumeHeaders.CurrentPage.FirstOrDefault(v => v.OxoDocId == filter.DocumentId);

            return summary;
        }
        public TakeRateDocumentHeader FdpVolumeHeaderSave(TakeRateDocumentHeader header)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpVolumHeaderId", header.FdpVolumeHeaderId, DbType.Int32, ParameterDirection.InputOutput);
                    para.Add("@CDSID", CurrentCDSID, DbType.String, size: 16);
                    if (header.ProgrammeId.HasValue) para.Add("@ProgrammeId", header.ProgrammeId.Value, DbType.Int32);
                    para.Add("@Gateway", header.Gateway, DbType.String);
                    para.Add("@FdpImportId", header.FdpImportId, DbType.Int32);
                    para.Add("@IsManuallyEntered", header.IsManuallyEntered, DbType.Boolean);
                    
                    var results = conn.Query<TakeRateDocumentHeader>(fdpVolumeHeaderSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    var takeRateDocumentHeaders = results as IList<TakeRateDocumentHeader> ?? results.ToList();
                    if (takeRateDocumentHeaders.Any())
                    {
                        header = takeRateDocumentHeaders.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderSave", ex.Message, CurrentCDSID);
                }
            }
            return header;
        }
        public PagedResults<TakeRateSummary> FdpTakeRateHeaderGetManyByUsername(TakeRateFilter filter)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                PagedResults<TakeRateSummary> retVal;
                try
                {
                    var para = new DynamicParameters();
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (filter.DocumentId.HasValue)
                    {
                        para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    }
                    if (filter.TakeRateId.HasValue)
                    {
                        para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, DbType.String, size: 50);
                    }
                    if (filter.TakeRateStatusId.HasValue)
                    {
                        para.Add("@FdpTakeRateStatusId", filter.TakeRateStatusId, DbType.Int32);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.Value, DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, DbType.Int32);
                    }
                    if (filter.SortDirection != SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }

                    // TODO implement the CDSId to get only those forecasts the user has permissions for
                    para.Add("@CDSId", CurrentCDSID, DbType.String);
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<TakeRateSummary>("dbo.Fdp_TakeRateHeader_GetManyByUsername", para, commandType: CommandType.StoredProcedure);
                    var takeRateSummaries = results as IList<TakeRateSummary> ?? results.ToList();
                    if (takeRateSummaries.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<TakeRateSummary>
                    {
                        PageIndex = filter.PageIndex ?? 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize ?? totalRecords
                    };

                    var currentPage = takeRateSummaries.ToList();

                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderGetManyByUsername", ex.Message, CurrentCDSID);
                    throw;
                }

                return retVal;
            }
        }
        public IEnumerable<TakeRateSummary> FdpVolumeHeaderGetManyByOxoDocIdAndUsername(TakeRateFilter filter)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<TakeRateSummary> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSID", CurrentCDSID, DbType.String, size: 16);
                    //para.Add("@DocumentId", filter.DocumentId, dbType: DbType.Int32);
                    
                    retVal = conn.Query<TakeRateSummary>(fdpVolumeHeaderByOxoDocumentStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderGetManyByOxoDocIdAndUsername", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }
        public void FdpOxoDocSave(FdpOxoDoc fdpOxoDocumentToSave)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSID", CurrentCDSID, DbType.String, size: 16);
                    para.Add("@FdpVolumeHeaderId", fdpOxoDocumentToSave.Header.TakeRateId, DbType.Int32);
                    para.Add("@DocumentId", fdpOxoDocumentToSave.Document.Id, DbType.Int32);

                    conn.Execute(fdpOxoDocSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderSaveMappingToOxoDocument", ex.Message, CurrentCDSID);
                }
            }
        }
        public IEnumerable<SpecialFeature> FdpSpecialFeatureTypeGetMany()
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                IEnumerable<SpecialFeature> retVal = null;
                try
                {
                    var para = new DynamicParameters();
     
                    retVal = conn.Query<SpecialFeature>(fdpSpecialFeatureTypeGetManyStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpSpecialFeatureTypeGetMany", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }

        public IEnumerable<TakeRateStatus> FdpTakeRateStatusGetMany()
        {
            var retVal = Enumerable.Empty<TakeRateStatus>();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    retVal = conn.Query<TakeRateStatus>("dbo.Fdp_TakeRateStatus_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpSpecialFeatureTypeGetMany", ex.Message, CurrentCDSID);
                }
            }
            return retVal;
        }

        #region "Private Members"

        private const string fdpVolumeHeaderStoredProcedureName = "Fdp_TakeRateHeader_GetManyByUsername";
        private const string fdpVolumeHeaderByOxoDocumentStoredProcedureName = "Fdp_VolumeHeader_GetManyByOxoDocId";
        private const string fdpVolumeHeaderSaveStoredProcedureName = "Fdp_TakeRateHeader_Save";
        private const string fdpOxoDocSaveStoredProcedureName = "Fdp_OxoDoc_Save";
        private const string fdpOxoDocProcessStoredProcedureName = "Fdp_OxoDoc_Process";
        private const string fdpTakeRateDataItemGetStoredProcedureName = "Fdp_TakeRateDataItem_Get";
        private const string fdpTakeRateModelSummaryItemGetStoredProcedureName = "Fdp_TakeRateModelSummaryItem_Get";
        private const string fdpTakeRateDataGetCrossTabStoredProcedureName = "Fdp_TakeRateData_GetCrossTab";
        private const string fdpTakeRateDataItemSaveStoredProcedureName = "Fdp_TakeRateDataItem_Save";
        private const string fdpTakeRateDataItemNoteGetManyStoredProcedureName = "Fdp_TakeRateDataItemNote_GetMany";
        private const string fdpTakeRateDataItemNoteSaveStoredProcedureName = "Fdp_TakeRateDataItemNote_Save";
        private const string fdpTakeRateDataItemHistoryGetManyStoredProcedureName = "Fdp_TakeRateDataItemHistory_GetMany";
        private const string fdpSpecialFeatureTypeGetManyStoredProcedureName = "Fdp_SpecialFeatureType_GetMany";

        #endregion

        public IEnumerable<TakeRateDataItem> FdpTakeRateByMarketGetMany(TakeRateFilter filter, decimal? newTakeRate)
        {
            var retVal = Enumerable.Empty<TakeRateDataItem>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
      
                    if (newTakeRate.HasValue) {
                        para.Add("@NewTakeRate", filter.NewTakeRate, DbType.Decimal);
                    }

                    retVal = conn.Query<TakeRateDataItem>("dbo.Fdp_TakeRateByMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<TakeRateDataItem> FdpVolumeByMarketGetMany(TakeRateFilter filter, int? newVolume)
        {
            IEnumerable<TakeRateDataItem> retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    if (newVolume.HasValue) {
                        para.Add("@NewVolume", filter.NewVolume, DbType.Int32);
                    }

                    retVal = conn.Query<TakeRateDataItem>("dbo.Fdp_TakeRateByVolume_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.TakeRateDataItemGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpChangeset FdpChangesetGet(FdpChangeset changesetToGet)
        {
            FdpChangeset retVal = new EmptyFdpChangeset();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpChangesetId", changesetToGet.FdpChangesetId, DbType.Int32);

                    // First resultset is the header information

                    var results = conn.QueryMultiple("dbo.Fdp_Changeset_Get", para, commandType: CommandType.StoredProcedure);
                    var firstResultSet = results.Read<FdpChangeset>();
                    var fdpChangesets = firstResultSet as IList<FdpChangeset> ?? firstResultSet.ToList();
                    if (firstResultSet == null || !fdpChangesets.Any())
                    {
                        return retVal;
                    }
                    retVal = fdpChangesets.First();

                    // Second resultset contains the data changes themselves

                    var secondResultSet = results.Read<DataChange>();
                    if (secondResultSet != null)
                    {
                        retVal.Changes = secondResultSet.ToList();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpChangesetGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }

        public IEnumerable<FdpChangeset> FdpMarketReviewChangesetsGetManu(TakeRateFilter filter)
        {
            IEnumerable<FdpChangeset> retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);

                    retVal = conn.Query<FdpChangeset>("dbo.FdpMarketReviewChangesetGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpLatestUnsavedChangesetByUserGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
           
            return retVal;
        }
        public FdpChangeset FdpLatestUnsavedChangesetByUserGetMany(TakeRateFilter filter)
        {
 	        FdpChangeset retVal = new EmptyFdpChangeset();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);
                    para.Add("@IsSaved", false, DbType.Boolean);

                    // First resultset is the header information

                    var results = conn.QueryMultiple("dbo.Fdp_Changeset_GetLatestByUser", para, commandType: CommandType.StoredProcedure);
                    var firstResultSet = results.Read<FdpChangeset>();
                    var fdpChangesets = firstResultSet as IList<FdpChangeset> ?? firstResultSet.ToList();
                    if (firstResultSet == null || !fdpChangesets.Any())
                    {
                        return retVal;
                    }
                    retVal = fdpChangesets.First();

                    // Second resultset contains the data changes themselves

                    var secondResultSet = results.Read<DataChange>();
                    if (secondResultSet != null)
                    {
                        retVal.Changes = secondResultSet.ToList();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpLatestUnsavedChangesetByUserGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpChangeset FdpChangesetSave(TakeRateFilter filter, FdpChangeset changeSetToSave)
        {
            FdpChangeset retVal = new EmptyFdpChangeset();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                   
                    var results = conn.Query<FdpChangeset>("dbo.Fdp_Changeset_Save", para, commandType: CommandType.StoredProcedure);
                    var fdpChangesets = results as IList<FdpChangeset> ?? results.ToList();
                    if (fdpChangesets.Any())
                    {
                        retVal = fdpChangesets.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpChangesetSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpChangeset FdpChangesetRevert(TakeRateFilter filter)
        {
            FdpChangeset retVal = new EmptyFdpChangeset();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);

                    var results = conn.QueryMultiple("dbo.Fdp_Changeset_Revert", para, commandType: CommandType.StoredProcedure);
                    var firstResultSet = results.Read<FdpChangeset>();
                    if (firstResultSet == null)
                    {
                        return retVal;
                    }
                    retVal = firstResultSet.First();

                    var secondResultSet = results.Read<DataChange>();
                    if (secondResultSet == null)
                    {
                        return retVal;
                    }
                    retVal.Changes = secondResultSet.ToList();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpChangesetRevert", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpChangeset FdpChangesetPersist(TakeRateFilter filter, FdpChangeset changesetToPersist)
        {
            FdpChangeset retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        FdpChangesetPersist(changesetToPersist, tran);
                        FdpChangesetMarkSaved(changesetToPersist, tran);

                        tran.Commit();

                        retVal = FdpChangesetGet(changesetToPersist);
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("TakeRateDataStore.FdpChangesetPersist", ex.Message, CurrentCDSID);
                        throw;
                    }
                }
            }
            return retVal;
        }
        public FdpChangeset FdpChangesetUndo(TakeRateFilter takeRateFilter, FdpChangeset changesetToUndo)
        {
            FdpChangeset retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetId", changesetToUndo.FdpChangesetId, DbType.Int32);

                        var revertedItems = conn.Query<DataChange>("dbo.Fdp_Changeset_Undo", para, tran, commandType: CommandType.StoredProcedure);

                        tran.Commit();

                        retVal = FdpChangesetGet(changesetToUndo);
                        var dataChanges = revertedItems as IList<DataChange> ?? revertedItems.ToList();
                        if (dataChanges.Any())
                        {
                            retVal.Reverted = dataChanges.ToList();
                        }
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("TakeRateDataStore.FdpChangesetUndo", ex.Message, CurrentCDSID);
                        throw;
                    }
                }
            }
            return retVal;
        }
        private static void FdpChangesetPersist(FdpChangeset changesetToPersist, IDbTransaction tran)
        {
            var para = new DynamicParameters();
            para.Add("@FdpChangesetId", changesetToPersist.FdpChangesetId, DbType.Int32);

            tran.Connection.Execute("dbo.Fdp_Changeset_PersistChanges", para, tran, commandType: CommandType.StoredProcedure);
        }
        private static void FdpChangesetMarkSaved(FdpChangeset changesetToMark, IDbTransaction tran)
        {
            var para = new DynamicParameters();
            para.Add("@FdpChangesetId", changesetToMark.FdpChangesetId, DbType.Int32);

            tran.Connection.Execute("dbo.Fdp_Changeset_MarkSaved", para, tran, commandType: CommandType.StoredProcedure);
        }
        public DataChange FdpChangesetDataItemSave(TakeRateFilter filter, DataChange dataItemToSave)
        {
            DataChange retVal = new EmptyDataChange();

            using (var conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetId", dataItemToSave.FdpChangesetId.GetValueOrDefault(), DbType.Int32);
                        para.Add("@MarketId", dataItemToSave.MarketId, DbType.Int32);
                        para.Add(!dataItemToSave.IsFdpModel ? "@ModelId" : "@FdpModelId", dataItemToSave.GetModelId(),
                            DbType.Int32);
                        para.Add(!dataItemToSave.IsFdpFeature ? "@FeatureId" : "@FdpFeatureId",
                            dataItemToSave.GetFeatureId(), DbType.Int32);

                        if (dataItemToSave.Volume.HasValue)
                        {
                            para.Add("@TotalVolume", dataItemToSave.Volume, DbType.Int32);
                        }
                        if (dataItemToSave.PercentageTakeRateAsFraction.HasValue)
                        {
                            para.Add("@PercentageTakeRate", dataItemToSave.PercentageTakeRateAsFraction, DbType.Decimal);
                        }
                        var results = conn.Query<DataChange>("dbo.Fdp_ChangesetDataItem_Save", para, tran, commandType: CommandType.StoredProcedure);
                        var dataChanges = results as IList<DataChange> ?? results.ToList();
                        if (dataChanges.Any())
                        {
                            retVal = dataChanges.First();
                        }
                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("FdpVolumeDataStore.FdpChangesetSave", ex.Message, CurrentCDSID);
                        throw;
                    }
                }
            }
            return retVal;
        }
        public DataChange FdpChangesetDataItemRecalculate(DataChange changeToRecalculate)
        {
            DataChange retVal = new EmptyDataChange();

            using (var conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetDataItemId", changeToRecalculate.FdpChangesetDataItemId.GetValueOrDefault(), DbType.Int32);
                        var results = conn.Query<DataChange>("dbo.Fdp_ChangesetDataItem_Recalculate", para, tran, commandType: CommandType.StoredProcedure);
                        var dataChanges = results as IList<DataChange> ?? results.ToList();
                        if (dataChanges.Any())
                        {
                            retVal = dataChanges.First();
                        }

                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("FdpVolumeDataStore.FdpChangesetDataItemRecalculate", ex.Message, CurrentCDSID);
                        throw;
                    }
                }
            }
            return retVal;
        }

        public int FdpVolumeByMarketAndModelGet(TakeRateFilter filter)
        {
            var retVal = 0;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);

                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    para.Add("@ModelId", filter.ModelId, DbType.Int32);
                    para.Add("@FdpModelId", filter.FdpModelId, DbType.Int32);

                    var results = conn.Query<int>("dbo.Fdp_VolumeByMarketAndModel_Get", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<int> ?? results.ToList();
                    if (results != null && enumerable.Any())
                    {
                        retVal = enumerable.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("TakeRateDataStore.FdpVolumeByMarketAndModelGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }

        public int FdpVolumeByMarketGet(TakeRateFilter filter)
        {
            var retVal = 0;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);

                    var results = conn.Query<int>("dbo.Fdp_VolumeByMarket_Get", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<int> ?? results.ToList();
                    if (results != null && enumerable.Any())
                    {
                        retVal = enumerable.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("TakeRateDataStore.FdpVolumeByMarketGet", ex.Message, CurrentCDSID);
                }
            }
            return retVal;
        }
    }
}
