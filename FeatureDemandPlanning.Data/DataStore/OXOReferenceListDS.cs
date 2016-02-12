using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class ReferenceListDataStore: DataStoreBase
    {
        public ReferenceListDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<ReferenceList> ReferenceListGetMany(string listName)
        {
            IEnumerable<ReferenceList> retVal = null;
          
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_list_name", listName, dbType: DbType.String, size: 100);
                    retVal = conn.Query<ReferenceList>("dbo.OXO_Reference_List_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }          
            }

            return retVal;   
        }

        public ReferenceList ReferenceListGet(int id)
        {
            ReferenceList retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<ReferenceList>("dbo.OXO_Reference_List_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }

            return retVal;
        }

        public bool ReferenceListSave(ReferenceList obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_Reference_List_New" : "dbo.OXO_Reference_List_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@p_Code", obj.Code, dbType: DbType.String, size: 50);
                    para.Add("@p_Description", obj.Description, dbType: DbType.String, size: 500);
                    para.Add("@p_List_Name", obj.ListName, dbType: DbType.String, size: 100);
                    para.Add("@p_Display_Order", obj.DisplayOrder, dbType: DbType.Int32);

                    if (obj.Id == 0)
                        para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    else
                        para.Add("@p_Id", obj.Id, dbType: DbType.Int32);
                   
                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    if (obj.Id == 0)
                        obj.Id = para.Get<int>("@p_Id");  
                 
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
            
        }

        public bool ReferenceListDelete(int id)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Reference_List_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
    }
}