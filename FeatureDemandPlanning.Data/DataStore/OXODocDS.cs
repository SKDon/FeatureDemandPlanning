using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using System.Data.SqlClient;
using System.Diagnostics;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model.Filters;

namespace FeatureDemandPlanning.DataStore
{
    public class OXODocDataStore : DataStoreBase
    {
        public OXODocDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public DataRow[] ItemData(OXODoc doc, OXOSection section, string mode, int objectId, string modelIds)
        {
            OXODocDataStore ds = new OXODocDataStore("system");
            var retVal = ds.OXODocGetItemData(doc.VehicleMake, doc.Id, doc.ProgrammeId, section.ToString(), mode, objectId, modelIds);
            return retVal;
        }

        public DataRowCollection ItemDataCol(OXODoc doc, OXOSection section, string mode, int objectId, string modelIds)
        {
            OXODocDataStore ds = new OXODocDataStore("system");
            var retVal = ds.OXODocGetItemDataCol(doc.VehicleMake, doc.Id, doc.ProgrammeId, section.ToString(), mode, objectId, modelIds);
            return retVal;
        }

        public IEnumerable<OXODataItemHistory> ItemDataHistory(OXODoc doc, OXOSection section, int modelId, int marketgroupId, int marketId, int featureId)
        {
            OXODocDataStore ds = new OXODocDataStore("system");
            var retVal = ds.OXODocGetItemDataHistory(doc.Id, section.ToString(), modelId, marketgroupId, marketId, featureId);
            return retVal;
        }

        public IEnumerable<OXODoc> OXODocGetMany(int ProgrammeId)
        {
            IEnumerable<OXODoc> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_programme_id", ProgrammeId, dbType: DbType.Int32);
                    retVal = conn.Query<OXODoc>("dbo.OXO_OXODoc_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<OXODoc> OXODocGetManyByVehicle(string vehicleName)
        {
            IEnumerable<OXODoc> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_vehicle_Name", vehicleName, dbType: DbType.String, size: 50);
                    retVal = conn.Query<OXODoc>("dbo.OXO_OXODoc_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGetManyByVehicle", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<OXODoc> OXODocGetManyByUser(string cdsid)
        {
            IEnumerable<OXODoc> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_cdsid", cdsid, dbType: DbType.String, size:8);
                    retVal = conn.Query<OXODoc>("dbo.OXO_OXODoc_GetManyByUser", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGetManyByUser", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public OXODoc OXODocGet(int id, int progid)
        {
            OXODoc retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    para.Add("@p_Programme_Id", progid, dbType: DbType.Int32);
                    retVal = conn.Query<OXODoc>("dbo.OXO_OXODoc_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGet", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public bool OXODocSave(OXODoc obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_OXODoc_New" : "dbo.OXO_OXODoc_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    obj.Save(this.CurrentCDSID);

                    var para = new DynamicParameters();
                    para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@p_Gateway", obj.Gateway, dbType: DbType.String, size: 50);
                    para.Add("@p_Version_Id", obj.VersionId, dbType: DbType.Decimal);
                    para.Add("@p_Status", obj.Status, dbType: DbType.String, size: 50);
                    if (obj.IsNew)
                    {
                        para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
                        para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
                    }
                    para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
                    para.Add("@p_Id", obj.Id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    if (obj.Id == 0)
                    {
                        obj.Id = para.Get<int>("@p_Id");
                    }

                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }

            }
            return retVal;

        }

        public bool OXODocDelete(int id)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_OXODoc_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public DataRow[] OXODocGetItemData(string make, int docId, int progId, string section, string mode, int objectId, string modelIds, bool export=false)
        {

            Stopwatch stopWatch = new Stopwatch();
            DataRow[] retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                using (SqlCommand cmd = new SqlCommand(@"dbo.OXO_Data_GetCrossTab_Wrapper", (SqlConnection)conn))
                {
                    try
                    {

                        stopWatch.Reset();
                        stopWatch.Start();

                        cmd.CommandTimeout = 0;
                        SqlDataAdapter adapt = new SqlDataAdapter(cmd);
                        adapt.SelectCommand.CommandType = CommandType.StoredProcedure;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_make", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_make"].Value = make;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_doc_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_doc_id"].Value = docId;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_prog_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_prog_id"].Value = progId;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_section", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_section"].Value = section;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_mode", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_mode"].Value = mode;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_object_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_object_id"].Value = objectId;  
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_model_ids", SqlDbType.NVarChar, -1));
                        adapt.SelectCommand.Parameters["@p_model_ids"].Value = modelIds;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_export", SqlDbType.Bit, -1));
                        adapt.SelectCommand.Parameters["@p_export"].Value = export;

                        DataTable dt = new DataTable();
                        adapt.Fill(dt);


                        retVal = dt.AsEnumerable().ToArray();

                        stopWatch.Stop();
                        var executionTime = stopWatch.ElapsedMilliseconds;

                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("OXODocDataStore.OXODocGetItemData", ex.Message, CurrentCDSID);
                    }
                }

            }
            return retVal;
        }

        public DataRowCollection OXODocGetItemDataCol(string make, int docId, int progId, string section, string mode, int objectId, string modelIds)
        {
            Stopwatch stopWatch = new Stopwatch();    
            DataRowCollection retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                using (SqlCommand cmd = new SqlCommand(@"dbo.OXO_Data_GetCrossTab_Wrapper", (SqlConnection)conn))
                {
                    try
                    {
                        cmd.CommandTimeout = 0;
                        SqlDataAdapter adapt = new SqlDataAdapter(cmd);
                        adapt.SelectCommand.CommandType = CommandType.StoredProcedure;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_make", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_make"].Value = make;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_doc_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_doc_id"].Value = docId;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_prog_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_prog_id"].Value = progId;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_section", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_section"].Value = section;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_mode", SqlDbType.NVarChar, 50));
                        adapt.SelectCommand.Parameters["@p_mode"].Value = mode;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_object_id", SqlDbType.Int));
                        adapt.SelectCommand.Parameters["@p_object_id"].Value = objectId;
                        adapt.SelectCommand.Parameters.Add(new SqlParameter("@p_model_ids", SqlDbType.NVarChar, -1));
                        adapt.SelectCommand.Parameters["@p_model_ids"].Value = modelIds;

                        DataTable dt = new DataTable();
                        adapt.Fill(dt);

                        stopWatch.Reset();
                        stopWatch.Start();

                        retVal = dt.Rows;

                        stopWatch.Stop();
                        var executionTime = stopWatch.ElapsedMilliseconds;
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("OXODocDataStore.OXODocGetItemData", ex.Message, CurrentCDSID);
                    }
                }

            }
            return retVal;
        }

        public bool OXODocBulkInsertUpdate(int docId, string reminder, int progId, OXODataItem[] data, string section) 
        {
            bool isNew = (docId == 0 ? true : false);
            bool retVal = true;
            String guid = System.Guid.NewGuid().ToString();

            //First Step - create a empty OXO doc if isNew 
            if (isNew)
            {
                OXODoc newDoc = new OXODoc();
                newDoc.Active = true;
                newDoc.ProgrammeId = progId;
                newDoc.Save(this.CurrentCDSID);
                retVal = this.OXODocSave(newDoc);
                docId = newDoc.Id;
            }
            if (retVal)
            {               
                //first bulk insert all data - no need for transaction here;
                DataTable tempTable = GetOXOTempDataTable();
                foreach (OXODataItem item in data)
                {
                    int? marketid;
                    if (item.MarketId == 0)
                        marketid = null;
                    else
                        marketid = item.MarketId;

                    int? marketgroupid;
                    if (item.MarketGroupId == 0)
                        marketgroupid = null;
                    else
                        marketgroupid = item.MarketGroupId;

                    int? featureid;
                    if (item.FeatureId == 0)
                        featureid = null;
                    else
                        featureid = item.FeatureId;

                    int? packid;
                    if (item.PackId == 0)
                        packid = null;
                    else
                        packid = item.PackId;

                    tempTable.Rows.Add(new Object[] { 0, guid, item.Section, item.ModelId, marketid, marketgroupid, featureid, packid, docId, item.Code, reminder });
                }

                using (IDbConnection conn = DbHelper.GetDBConnection())
                {
                    using (SqlBulkCopy bulk = new SqlBulkCopy((SqlConnection)conn))
                    {
                        conn.Open();
                        bulk.DestinationTableName = "dbo.OXO_Temp_Working_Data";
                        bulk.WriteToServer(tempTable);
                        bulk.Close();
                        conn.Close();
                    }
                }

                // continute with update
                string procName = "dbo.OXO_OXODoc_Bulk_Update";
                using (IDbConnection conn = DbHelper.GetDBConnection())
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@p_GUID", guid, dbType: DbType.String, size:500);
                        para.Add("@p_Doc_Id", docId, dbType: DbType.Int32);
                        para.Add("@p_Section", section, dbType: DbType.String, size: 50);
                        para.Add("@p_Updated_By", CurrentCDSID, dbType: DbType.String, size: 8);
                        conn.Execute(procName, para, commandType: CommandType.StoredProcedure, commandTimeout: 0);
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("OXODocDataStore.OXODocBulkUpdate", ex.Message, CurrentCDSID);
                        retVal = false;
                    }
                }
               
            }

            return retVal;
        }

        public DataTable GetOXOTempDataTable()
        {
            DataTable table = new DataTable();
            table.Columns.Add("ID", typeof(Int32));
            table.Columns.Add("GUID", typeof(string));
            table.Columns.Add("Section", typeof(string));
            table.Columns.Add("Model_Id", typeof(Int32));
            table.Columns.Add("Model_Group_Id", typeof(Int32));
            table.Columns.Add("Market_Id", typeof(Int32));
            table.Columns.Add("Feature_Id", typeof(Int32));
            table.Columns.Add("Pack_Id", typeof(Int32));
            table.Columns.Add("OXO_Doc_Id", typeof(Int32));
            table.Columns.Add("OXO_Code", typeof(string));
            table.Columns.Add("Reminder", typeof(string));
            return table;
        }

        public IEnumerable<OXODataItemHistory> OXODocGetItemDataHistory(int docId, string section, int modelId, int marketgroupId, int marketId, int featureId)
        {
            IEnumerable<OXODataItemHistory> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_section", section, dbType: DbType.String, size:8);
                    para.Add("@p_model_id", modelId, dbType: DbType.Int32);
                    para.Add("@p_market_id", marketId, dbType: DbType.Int32);
                    para.Add("@p_market_group_Id", marketgroupId, dbType: DbType.Int32);
                    para.Add("@p_feature_id", featureId, dbType: DbType.Int32);
                    retVal = conn.Query<OXODataItemHistory>("dbo.OXO_Data_Change_History", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGetItemDataHistory", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<Model.Model> OXODocAvailableModelsByMarketGroup(int progId, int docId, int marketGroupId)
        {
            IEnumerable<Model.Model> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_group_id", marketGroupId, dbType: DbType.Int32);
                    retVal = conn.Query<Model.Model>("dbo.OXO_AvailableModel_MarketGroup", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocAvailableModelsByMarketGroup", ex.Message, CurrentCDSID);
                }

            }
            return retVal;

        }

        public IEnumerable<Model.Model> OXODocAvailableModelsByMarket(int progId, int docId, int marketId)
        {
            IEnumerable<Model.Model> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_market_id", marketId, dbType: DbType.Int32);
                    retVal = conn.Query<Model.Model>("dbo.OXO_AvailableModel_Market", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocAvailableModelsByMarket", ex.Message, CurrentCDSID);
                }

            }
            return retVal;                
        }

        public IEnumerable<FdpModel> FdpModelsByMarketGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpModel> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ProgrammeId", filter.ProgrammeId, DbType.Int32);
                    para.Add("@OxoDocId", filter.OxoDocId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);
                    retVal = conn.Query<FdpModel>("dbo.Fdp_AvailableModelByMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.FdpModelsByMarketGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public IEnumerable<FdpModel> FdpModelsByMarketGroupGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpModel> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ProgrammeId", filter.ProgrammeId, DbType.Int32);
                    para.Add("@OxoDocId", filter.OxoDocId, DbType.Int32);
                    para.Add("@MarketGroupId", filter.MarketGroupId, DbType.Int32);
                    retVal = conn.Query<FdpModel>("dbo.Fdp_AvailableModelByMarketGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.FdpModelsByMarketGroupGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<OXODataChain> OXODocGetItemDataChain(string option, int docId, int progId, int modelId, int featureId, string level, int objectId)
        {
            string procName = (option == "Up" ? "dbo.OXO_Chain_Up_GetMany" : "dbo.OXO_Chain_Down_GetMany");

            IEnumerable<OXODataChain> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_model_id", modelId, dbType: DbType.Int32);
                    para.Add("@p_feature_id", featureId, dbType: DbType.Int32);
                    para.Add("@p_level", level, dbType: DbType.String, size: 10);
                    para.Add("@p_object_id", objectId, dbType: DbType.Int32);

                    retVal = conn.Query<OXODataChain>(procName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocGetItemDataChain", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public int OXODocValidateEFG(int id, int progid)
        {
            int retVal = 0;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", id, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@rec_count", null, dbType: DbType.Int32, direction: ParameterDirection.Output);
                    conn.Execute("dbo.OXO_OXODoc_ValidateEFGs", para, commandType: CommandType.StoredProcedure);
                    retVal = para.Get<int>("@rec_count");
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocValidateEFG", ex.Message, CurrentCDSID);
                    retVal = -1000;
                }
            }

            return retVal;
        }

        public int OXODocValidateEmptyCells(int id, int progid)
        {
            int retVal = 0;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", id, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@rec_count", null, dbType: DbType.Int32, direction: ParameterDirection.Output);
                    conn.Execute("dbo.OXO_OXODoc_ValidateEmptyCells", para, commandType: CommandType.StoredProcedure);
                    retVal = para.Get<int>("@rec_count");
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.OXODocValidateEmptyCells", ex.Message, CurrentCDSID);
                    retVal = -1000;
                }
            }

            return retVal;
        }

        public IEnumerable<Gateway> GatewayGetMany()
        {
            IEnumerable<Gateway> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Gateway>("dbo.OXO_Gateway_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDataStore.GatewayGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public bool OXOCloneForwardDoc(int docId, int progId, int newProgId, string gateway, string donor, decimal versionId)
        {
            bool retVal = false;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IDbTransaction transaction = null;
                try
                {
                    conn.Open();
                    transaction = conn.BeginTransaction();
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_new_prog_id", newProgId, dbType: DbType.Int32);
                    para.Add("@p_gateway", gateway, dbType: DbType.String, size: 50);
                    para.Add("@p_donor", donor, dbType: DbType.String, size: 500);
                    para.Add("@p_version_id", versionId, dbType: DbType.Decimal);
                    para.Add("@p_clone_by", CurrentCDSID, dbType: DbType.String, size: 50);
                    conn.Execute("dbo.OXO_Doc_Clone_Forward_Doc", para, transaction, commandType: CommandType.StoredProcedure);
                    transaction.Commit();
                    retVal = true;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    retVal = false;
                    AppHelper.LogError("OXODocDataStore.OXOCloneForwardDoc", ex.Message, CurrentCDSID);
                }
                finally
                {
                    conn.Close();
                }

            }

            return retVal;
        }

        public int OXOCloneGatewayDoc(int docId, int progId, string gateway, string nextGateway, decimal versionId)
        {
            int newDocId = 0;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IDbTransaction transaction = null;
                try
                {
                    conn.Open();
                    transaction = conn.BeginTransaction();
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_gateway", gateway, dbType: DbType.String, size: 50);
                    para.Add("@p_next_gateway", nextGateway, dbType: DbType.String, size: 50);               
                    para.Add("@p_version_id", versionId, dbType: DbType.Decimal);
                    para.Add("@p_clone_by", CurrentCDSID, dbType: DbType.String, size: 50);
                    para.Add("@p_new_doc_id", newDocId, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);             
                    conn.Execute("dbo.OXO_Doc_Clone_Gateway_Doc", para, transaction, commandType: CommandType.StoredProcedure);
                    newDocId = para.Get<int>("@p_new_doc_id");
                    transaction.Commit();                   

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    newDocId = -1000;
                    AppHelper.LogError("OXODocDataStore.OXOCloneGatewayDoc", ex.Message, CurrentCDSID);
                }
                finally
                {
                    conn.Close();
                }

            }

            return newDocId;
        }

        public void DocGetConfiguration(OXODoc currentDoc)
        {
            Programme retVal = new Programme();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_doc_id", currentDoc.Id, dbType: DbType.Int32);
                    using (var multi = conn.QueryMultiple("dbo.OXO_Doc_GetConfiguration", para, commandType: CommandType.StoredProcedure))
                    {
                        currentDoc.AllBodies = multi.Read<ModelBody>().ToList();
                        currentDoc.AllEngines = multi.Read<ModelEngine>().ToList();
                        currentDoc.AllTransmissions = multi.Read<ModelTransmission>().ToList();
                        currentDoc.AllTrims = multi.Read<ModelTrim>().ToList();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODocDS.DocGetConfiguration", ex.Message, CurrentCDSID);
                }
            }

     
        }

    }
}