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

namespace FeatureDemandPlanning.DataStore
{
    public class FdpVolumeDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public FdpVolumeDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        #endregion

        public ImportResult ImportData(string filePath)
        {
            throw new NotImplementedException();
        }

        public FdpOxoVolumeDataItem FdpOxoVolumeDataItemGet(int fdpOxoVolumeDataItemId)
        {
            FdpOxoVolumeDataItem retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpOxoVolumeDataItemId", fdpOxoVolumeDataItemId, dbType: DbType.Int32);

                    retVal = conn.Query<FdpOxoVolumeDataItem>(fdpOxoVolumeDataGetStoredProcedureName, para, commandType: CommandType.StoredProcedure)
                                 .FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataItemSave", ex.Message, CurrentCDSID);
                }
            }
            return retVal;
        }

        public VolumeData FdpOxoVolumeDataItemList(VolumeFilter filter)
        {
            VolumeData retVal = new VolumeData();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var cmd = conn.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "Fdp_OxoVolumeDataItem_GetCrossTab";
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
                    retVal.VolumeByModel = ds.Tables[2].AsEnumerable().Select(d => new DerivativeVolumeData()
                    {
                        ModelId = d.Field<int>("Model_Id"),
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
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataItemGetCrossTab", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }

        public void FdpOxoVolumeDataItemSave(FdpOxoVolumeDataItem dataItemToSave)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpOxoVolumeDataId", dataItemToSave.FdpOxoVolumeDataItemId.Value, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
                    para.Add("@Section", dataItemToSave.Section, dbType: DbType.String);
                    para.Add("@ModelId", dataItemToSave.ModelId, dbType: DbType.Int32);
                    para.Add("@MarketGroupId", dataItemToSave.MarketGroupId, dbType: DbType.Int32);
                    para.Add("@MarketId", dataItemToSave.MarketId, dbType: DbType.Int32);
                    para.Add("@OxoDocId", dataItemToSave.OxoDocId, dbType: DbType.Int32);
                    para.Add("@Volume", dataItemToSave.Volume, dbType: DbType.Int32);
                    para.Add("@PercentageTakeRate", dataItemToSave.PercentageTakeRate, dbType: DbType.Decimal);
                    para.Add("@PackId", dataItemToSave.PackId, dbType: DbType.Int32);
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String);

                    int results = conn.Execute(fdpOxoVolumeDataSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);

                    if (results != 0)
                    {
                        dataItemToSave.FdpOxoVolumeDataItemId = para.Get<int>("@FdpOxoVolumeDataId");
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataItemSave", ex.Message, CurrentCDSID);
                }
            }
        }
        public IEnumerable<FdpOxoVolumeDataItemNote> FdpOxoVolumeDataItemNoteGetMany(int fdpOxoVolumeDataItemId)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<FdpOxoVolumeDataItemNote> retVal = Enumerable.Empty<FdpOxoVolumeDataItemNote>();
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpOxoVolumeDataId", fdpOxoVolumeDataItemId, dbType: DbType.Int32);

                    retVal = conn.Query<FdpOxoVolumeDataItemNote>(fdpOxoVolumeDataNoteGetManyStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataItemNoteGetMany", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }
        public void FdpOxoVolumeDataItemNoteSave(FdpOxoVolumeDataItemNote noteToSave, FdpOxoVolumeDataItem forData)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpOxoVolumeDataId", forData.FdpOxoVolumeDataItemId.Value, dbType: DbType.Int32);
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String);
                    para.Add("@Note", noteToSave.Note, dbType: DbType.String);
                    para.Add("@FdpOxoVolumeDataNoteId", null, DbType.Int32, direction: ParameterDirection.Output);

                    int results = conn.Execute(fdpOxoVolumeDataNoteSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);

                    if (results != 0)
                    {
                        noteToSave.FdpOxoVolumeDataItemNoteId = para.Get<int>("@FdpOxoVolumeDataNoteId");
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataNoteSave", ex.Message, CurrentCDSID);
                }
            }
        }
        public IEnumerable<FdpOxoVolumeDataItemHistory> FdpOxoVolumeDataItemHistoryGetMany(int fdpOxoVolumeDataItemId)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<FdpOxoVolumeDataItemHistory> retVal = Enumerable.Empty<FdpOxoVolumeDataItemHistory>();
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpOxoVolumeDataId", fdpOxoVolumeDataItemId, dbType: DbType.Int32);

                    retVal = conn.Query<FdpOxoVolumeDataItemHistory>(fdpOxoVolumeDataHistoryGetManyStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpOxoVolumeDataHistoryGetMany", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }
        public VolumeSummary FdpVolumeHeaderGet(int fdpVolumeHeaderId)
        {
            var volumeHeaders = FdpVolumeHeaderGetManyByUsername(new TakeRateFilter());
            if (volumeHeaders == null || !volumeHeaders.Any())
                return null;

            return volumeHeaders.Where(v => v.FdpVolumeHeaderId == fdpVolumeHeaderId).FirstOrDefault();
        }
        public void FdpVolumeHeaderSave(FdpVolumeHeader header)
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
                    
                    var rows = conn.Execute(fdpVolumeHeaderSaveStoredProcedureName, para, commandType: CommandType.StoredProcedure);

                    if (rows != 0)
                    {
                        header.FdpVolumeHeaderId = para.Get<int>("@FdpVolumeHeaderId");
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderSave", ex.Message, CurrentCDSID);
                }
            }
        }
        public IEnumerable<VolumeSummary> FdpVolumeHeaderGetManyByUsername(TakeRateFilter filter)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<VolumeSummary> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String, size: 16);

                    if (!string.IsNullOrEmpty(filter.Code))
                    {
                        para.Add("@VehicleName", filter.Code, dbType: DbType.String, size: 1000);
                    }

                    if (!string.IsNullOrEmpty(filter.ModelYear))
                    {
                        para.Add("@ModelYear", filter.ModelYear, dbType: DbType.String, size: 100);
                    }

                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, dbType: DbType.String, size: 50);
                    }

                    retVal = conn.Query<VolumeSummary>(fdpVolumeHeaderStoredProcedureName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpVolumeHeaderGetManyByUsername", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }
        public IEnumerable<VolumeSummary> FdpVolumeHeaderGetManyByOxoDocIdAndUsername(TakeRateFilter filter)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<VolumeSummary> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSID", this.CurrentCDSID, dbType: DbType.String, size: 16);
                    //para.Add("@OxoDocId", filter.OxoDocId, dbType: DbType.Int32);
                    
                    retVal = conn.Query<VolumeSummary>(fdpVolumeHeaderByOxoDocumentStoredProcedureName, para, commandType: CommandType.StoredProcedure);
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
                    para.Add("@FdpVolumeHeaderId", fdpOxoDocumentToSave.Header.FdpVolumeHeaderId, dbType: DbType.Int32);
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

        #region "Private Members"

        private const string fdpVolumeHeaderStoredProcedureName = "Fdp_VolumeHeader_GetManyByUsername";
        private const string fdpVolumeHeaderByOxoDocumentStoredProcedureName = "Fdp_VolumeHeader_GetManyByOxoDocId";
        private const string fdpVolumeHeaderSaveStoredProcedureName = "Fdp_VolumeHeader_Save";
        private const string fdpOxoDocSaveStoredProcedureName = "Fdp_OxoDoc_Save";
        private const string fdpOxoDocProcessStoredProcedureName = "Fdp_OxoDoc_Process";
        private const string fdpOxoVolumeDataGetStoredProcedureName = "Fdp_OxoVolumeDataItem_Get";
        private const string fdpOxoVolumeDataGetCrossTabStoredProcedureName = "Fdp_OxoVolumeDataItem_GetCrossTab";
        private const string fdpOxoVolumeDataSaveStoredProcedureName = "Fdp_OxoVolumeDataItem_Save";
        private const string fdpOxoVolumeDataNoteGetManyStoredProcedureName = "Fdp_OxoVolumeDataNote_GetMany";
        private const string fdpOxoVolumeDataNoteSaveStoredProcedureName = "Fdp_OxoVolumeDataNote_Save";
        private const string fdpOxoVolumeDataHistoryGetManyStoredProcedureName = "Fdp_OxoVolumeDataHistory_GetMany";
        private const string fdpSpecialFeatureTypeGetManyStoredProcedureName = "Fdp_SpecialFeatureType_GetMany";

        #endregion
    }
}
