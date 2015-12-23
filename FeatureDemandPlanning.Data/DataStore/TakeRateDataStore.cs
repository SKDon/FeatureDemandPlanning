using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using FeatureDemandPlanning.DataStore.DataStore;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.DataStore
{
    public class TakeRateDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public TakeRateDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        #endregion

        public ImportResult ImportData(string filePath)
        {
            throw new NotImplementedException();
        }

        public TakeRateDataItem TakeRateDataItemGet(TakeRateFilter filter)
        {
            TakeRateDataItem retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
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
        public TakeRateData TakeRateDataItemList(TakeRateFilter filter)
        {
            TakeRateData retVal = new TakeRateData();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var cmd = conn.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "Fdp_TakeRateData_GetCrossTab";
                    cmd.CommandTimeout = 0;

                    cmd.Parameters.Add(new SqlParameter("@OxoDocId", SqlDbType.Int) { Value = filter.OxoDocId.Value });
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

                    if (filter.Mode == FeatureDemandPlanning.Model.Enumerations.TakeRateResultMode.PercentageTakeRate)
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
                    retVal.TakeRateSummaryByModel = ds.Tables[2].AsEnumerable().Select(d => new ModelTakeRateSummary()
                    {
                        StringIdentifier = d.Field<string>("StringIdentifier"),
                        IsFdpModel = d.Field<bool>("IsFdpModel"),
                        Volume = d.Field<int>("Volume"),
                        PercentageOfFilteredVolume = d.Field<decimal>("PercentageOfFilteredVolume")
                    });

                    // 4. Summary information
                    var summary = ds.Tables[3].AsEnumerable().FirstOrDefault();

                    retVal.TotalVolume = summary.Field<int>("TotalVolume");
                    retVal.FilteredVolume = summary.Field<int>("FilteredVolume");
                    retVal.PercentageOfTotalVolume = summary.Field<decimal>("PercentageOfTotalVolume");
                    retVal.CreatedBy = summary.Field<string>("CreatedBy");
                    retVal.CreatedOn = summary.Field<DateTime>("CreatedOn");

                    // 5. Notes
                    retVal.NoteAvailability = ds.Tables[4].AsEnumerable().Select(n => new TakeRateDataItemNote()
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
                    para.Add("@CDSID", this.CurrentCDSID, DbType.String);

                    var rows = conn.Execute(fdpTakeRateDataItemSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    if (rows > 0)
                    {
                        takeRateDataItemId = para.Get<int?>("@FdpTakeRateDataItemId");
                    }
                    
                    // Save any notes 
                    foreach (var note in dataItemToSave.Notes.Where(n => !n.FdpTakeRateDataItemNoteId.HasValue))
                    {
                        note.FdpTakeRateDataItemId = takeRateDataItemId;
                        var savedNote = TakeRateDataItemNoteSave(note);
                    }

                    retVal = TakeRateDataItemGet(new TakeRateFilter() { TakeRateDataItemId = takeRateDataItemId });
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
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", noteToSave.FdpTakeRateDataItemId, DbType.Int32);
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String);
                    para.Add("@Note", noteToSave.Note, dbType: DbType.String);
                    
                    var results = conn.Query<TakeRateDataItemNote>(fdpTakeRateDataItemNoteSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
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
            IEnumerable<TakeRateDataItemNote> retVal = Enumerable.Empty<TakeRateDataItemNote>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", filter.TakeRateDataItemId, dbType: DbType.Int32);

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
            IEnumerable<TakeRateDataItemAudit> retVal = Enumerable.Empty<TakeRateDataItemAudit>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTakeRateDataItemId", filter.TakeRateDataItemId, dbType: DbType.Int32);

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

            return volumeHeaders.CurrentPage.Where(v => v.OxoDocId == filter.OxoDocId).FirstOrDefault();
        }
        public TakeRateDocumentHeader FdpVolumeHeaderSave(TakeRateDocumentHeader header)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpVolumHeaderId", header.FdpVolumeHeaderId, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String, size: 16);
                    para.Add("@ProgrammeId", header.ProgrammeId.Value, dbType: DbType.Int32);
                    para.Add("@Gateway", header.Gateway, dbType: DbType.String);
                    para.Add("@FdpImportId", header.FdpImportId, dbType: DbType.Int32);
                    para.Add("@IsManuallyEntered", header.IsManuallyEntered, dbType: DbType.Boolean);
                    
                    var results = conn.Query<TakeRateDocumentHeader>(fdpVolumeHeaderSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        header = results.First();
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
            var retVal = new PagedResults<TakeRateSummary>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (filter.TakeRateId.HasValue)
                    {
                        para.Add("@TakeRateId", filter.TakeRateId.Value, dbType: DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, dbType: DbType.String, size: 50);
                    }
                    if (filter.TakeRateStatusId.HasValue)
                    {
                        para.Add("@FdpTakeRateStatusId", filter.TakeRateStatusId, dbType: DbType.Int32);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, dbType: DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.SortDirection != Model.Enumerations.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == Model.Enumerations.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, dbType: DbType.String);
                    }

                    // TODO implement the CDSId to get only those forecasts the user has permissions for
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<TakeRateSummary>("dbo.Fdp_TakeRateHeader_GetManyByUsername", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<TakeRateSummary>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<TakeRateSummary>();
                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }

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
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String, size: 16);
                    //para.Add("@OxoDocId", filter.OxoDocId, dbType: DbType.Int32);
                    
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
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String, size: 16);
                    para.Add("@FdpVolumeHeaderId", fdpOxoDocumentToSave.Header.TakeRateId, dbType: DbType.Int32);
                    para.Add("@OxoDocId", fdpOxoDocumentToSave.Document.Id, dbType: DbType.Int32);

                    var rows = conn.Execute(fdpOxoDocSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderSaveMappingToOxoDocument", ex.Message, CurrentCDSID);
                }
            }
        }
        public IEnumerable<SpecialFeature> FdpSpecialFeatureTypeGetMany()
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
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
            using (IDbConnection conn = DbHelper.GetDBConnection())
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
        private const string fdpTakeRateDataGetCrossTabStoredProcedureName = "Fdp_TakeRateData_GetCrossTab";
        private const string fdpTakeRateDataItemSaveStoredProcedureName = "Fdp_TakeRateDataItem_Save";
        private const string fdpTakeRateDataItemNoteGetManyStoredProcedureName = "Fdp_TakeRateDataItemNote_GetMany";
        private const string fdpTakeRateDataItemNoteSaveStoredProcedureName = "Fdp_TakeRateDataItemNote_Save";
        private const string fdpTakeRateDataItemHistoryGetManyStoredProcedureName = "Fdp_TakeRateDataItemHistory_GetMany";
        private const string fdpSpecialFeatureTypeGetManyStoredProcedureName = "Fdp_SpecialFeatureType_GetMany";

        #endregion

        public IEnumerable<TakeRateDataItem> FdpTakeRateByMarketGetMany(TakeRateFilter filter, decimal? newTakeRate)
        {
            IEnumerable<TakeRateDataItem> retVal = Enumerable.Empty<TakeRateDataItem>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
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
            IEnumerable<TakeRateDataItem> retVal = Enumerable.Empty<TakeRateDataItem>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
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
    
        public FdpChangeset FdpLatestUnsavedChangesetByUserGetMany(TakeRateFilter filter)
        {
 	        FdpChangeset retVal = new EmptyFdpChangeset();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);
                    para.Add("@IsSaved", false, DbType.Boolean);

                    // First resultset is the header information

                    var results = conn.QueryMultiple("dbo.Fdp_Changeset_GetLatestByUser", para, commandType: CommandType.StoredProcedure);
                    var firstResultSet = results.Read<FdpChangeset>();
                    if (firstResultSet == null || !firstResultSet.Any())
                    {
                        return retVal;
                    }
                    retVal = firstResultSet.First();

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

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
                    para.Add("@CDSID", CurrentCDSID, DbType.String);
                   
                    var results = conn.Query<FdpChangeset>("dbo.Fdp_Changeset_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
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

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.OxoDocId, DbType.Int32);
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
        public FdpChangeset FdpChangesetPersist(TakeRateFilter filter, FdpChangeset changeSetToPersist)
        {
            FdpChangeset retVal = new EmptyFdpChangeset();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpChangesetId", changeSetToPersist.FdpChangesetId.GetValueOrDefault(), DbType.Int32);

                    var results = conn.Query("dbo.Fdp_Changeset_Persist", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("TakeRateDataStore.FdpChangesetPersist", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public DataChange FdpChangesetDataItemSave(TakeRateFilter filter, DataChange dataItemToSave)
        {
            DataChange retVal = new EmptyDataChange();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetId", dataItemToSave.FdpChangesetId.GetValueOrDefault(), DbType.Int32);
                        para.Add("@MarketId", dataItemToSave.MarketId, DbType.Int32);
                        if (!dataItemToSave.IsFdpModel)
                        {
                            para.Add("@ModelId", dataItemToSave.GetModelId(), DbType.Int32);
                        }
                        else
                        {
                            para.Add("@FdpModelId", dataItemToSave.GetModelId(), DbType.Int32);
                        }
                        if (!dataItemToSave.IsFdpFeature)
                        {
                            para.Add("@FeatureId", dataItemToSave.GetFeatureId(), DbType.Int32);
                        }
                        else
                        {
                            para.Add("@FdpFeatureId", dataItemToSave.GetFeatureId(), DbType.Int32);
                        }

                        if (dataItemToSave.Volume.HasValue)
                        {
                            para.Add("@TotalVolume", dataItemToSave.Volume, DbType.Int32);
                        }
                        if (dataItemToSave.PercentageTakeRateAsFraction.HasValue)
                        {
                            para.Add("@PercentageTakeRate", dataItemToSave.PercentageTakeRateAsFraction, DbType.Decimal);
                        }
                        var results = conn.Query<DataChange>("dbo.Fdp_ChangesetDataItem_Save", para, tran, commandType: CommandType.StoredProcedure);
                        if (results.Any())
                        {
                            retVal = results.First();
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
        public DataChange FdpChangesetDataItemPersist(TakeRateFilter filter, DataChange dataItemToPersist)
        {
            DataChange retVal = new EmptyDataChange();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetDataItemId", dataItemToPersist.FdpChangesetDataItemId.GetValueOrDefault(), DbType.Int32);

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

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@FdpChangesetDataItemId", changeToRecalculate.FdpChangesetDataItemId.GetValueOrDefault(), DbType.Int32);
                        var results = conn.Query<DataChange>("dbo.Fdp_ChangesetDataItem_Recalculate", para, tran, commandType: CommandType.StoredProcedure);
                        if (results.Any())
                        {
                            retVal = results.First();
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
            return 0;
        }

        public int FdpVolumeByMarketGet(TakeRateFilter filter)
        {
            return 0;
        }
    }
}
