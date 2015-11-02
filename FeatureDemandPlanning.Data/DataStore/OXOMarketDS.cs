using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using System.Data.SqlClient;

namespace FeatureDemandPlanning.DataStore
{
    public class MarketDataStore : DataStoreBase
    {
        
        public MarketDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<Market> MarketGetMany()
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<Market> MarketGetMany(int progId, int docId)
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Programme_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<Market> MarketGroupMarketGetMany()
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_MarketGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGroupGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public IEnumerable<Market> MarketAvailableGetMany(int progId)
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Market_AvailableGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketAvailableGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public Market MarketGet(int id)
        {
            Market retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Market_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGet", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }

        public bool MarketSave(Market obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_Market_New" : "dbo.OXO_Market_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    obj.Save(this.CurrentCDSID);

                    var para = new DynamicParameters();
                    para.Add("@p_Name", obj.Name, dbType: DbType.String, size: 500);
                    para.Add("@p_WHD", obj.WHD, dbType: DbType.String, size: 500);
                    para.Add("@p_PAR_X", obj.PAR_X, dbType: DbType.String, size: 500);
                    para.Add("@p_PAR_L", obj.PAR_L, dbType: DbType.String, size: 500);
                    para.Add("@p_Territory", obj.Territory, dbType: DbType.String, size: 500);
                    para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
                    para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
                    para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
                    para.Add("@p_Id", obj.Id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
                    
                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);
                    obj.Id = para.Get<int>("@p_Id");
        

                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }

            }
            return retVal;
            
        }

        public bool MarketDelete(int id)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Market_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool MarketGroupMarketDelete(int groupid, int marketid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_GroupId", groupid, dbType: DbType.Int32);
                    para.Add("@p_MarketId", marketid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Market_MarketGroup_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGroupMarketDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool MarketGroupMarketMove(int oldgroupid, int newgroupid, int marketid, string subgroupid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Old_GroupId", oldgroupid, dbType: DbType.Int32);
                    para.Add("@p_New_GroupId", newgroupid, dbType: DbType.Int32);
                    para.Add("@p_MarketId", marketid, dbType: DbType.Int32);
                    para.Add("@p_Sub_Group_Id", subgroupid, dbType: DbType.String, size: 500);
                    conn.Execute("dbo.OXO_Market_MarketGroup_Edit", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGroupMarketMove", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool MarketGroupMarketAdd(int groupid, Array aMarkets, string subRegion)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                foreach (var item in aMarkets)
                {
                    var para = new DynamicParameters();

                    try
                    {
                        para.Add("@p_GroupId", groupid, dbType: DbType.Int32);
                        para.Add("@p_MarketId", item, dbType: DbType.Int32);
                        para.Add("@p_SubRegion", subRegion, dbType: DbType.String, size: 500);
                        conn.Execute("dbo.OXO_Market_MarketGroup_New", para, commandType: CommandType.StoredProcedure);
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("MarketDataStore.MarketGroupMarketAdd", ex.Message, CurrentCDSID);
                        retVal = false;
                    }
                }
            }

            return retVal;
        }

        public IEnumerable<Market> TopMarketGetMany()
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGetMany::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGetMany::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }

            }
            return retVal;
        }

        public Market TopMarketGet(int marketId)
        {
            Market retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGet::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGet::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }

            }
            return retVal;
        }

        public Market TopMarketSave(Market marketToSave)
        {
            Market retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToSave.Id, dbType: DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, dbType: DbType.String);
                    para.Add("@TopMarketId", null, dbType: DbType.Int32, direction: ParameterDirection.Output);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_New", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketSave::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketSave::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }

            }
            return retVal;
        }

        public Market TopMarketDelete(Market marketToDelete)
        {
            Market retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToDelete.Id, dbType: DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, dbType: DbType.String);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketDelete::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketDelete::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }

            return retVal;
        }

    }
}