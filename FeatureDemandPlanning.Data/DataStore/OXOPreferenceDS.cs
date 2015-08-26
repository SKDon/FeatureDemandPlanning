using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class OXOPreferenceDataStore : DataStoreBase
    {
        public OXOPreferenceDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<NameValuePair> PreferenceGetMany(string cdsid)
        {
            IEnumerable<NameValuePair> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
                    para.Add("@p_CDSID", cdsid, dbType: DbType.String, size: 50);                 	    
					retVal = conn.Query<NameValuePair>("dbo.OXO_Preference_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
                    AppHelper.LogError("OXOPreferenceDataStore.PreferenceGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
        }

        public NameValuePair PreferenceGet(int id)
        {
            NameValuePair retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<NameValuePair>("dbo.OXO_Preference_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
				   AppHelper.LogError("OXOPreferenceDataStore.PreferenceGet", ex.Message, CurrentCDSID);
				}
			}

            return retVal;
        }

        //public bool PreferenceSave(NameValuePair obj)
        //{
        //    bool retVal = true;
        //    string procName = ("dbo.OXO_Preference_Edit");

        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {
        //            var para = new DynamicParameters();

        //             //para.Add("@p_CDSID", obj.CDSID, dbType: DbType.String, size: 50);
        //             //para.Add("@p_name", obj.ObjectType, dbType: DbType.String, size: 500);
        //             //para.Add("@p_value", obj.ObjectId, dbType: DbType.Int32);
        //             //para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 50);
        //             //para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
					    

        //            if (obj.Id == 0)
        //            {
        //                para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.Output);
        //            }
        //            else
        //            {
        //                para.Add("@p_Id", obj.Id, dbType: DbType.Int32);
        //            }

        //            conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

        //            if (obj.Id == 0)
        //            {
        //                obj.Id = para.Get<int>("@p_Id");
        //            }

        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("OXOPreferenceDataStore.PreferenceSave", ex.Message, CurrentCDSID);
        //            retVal = false;
        //        }
        //    }

        //    return retVal;
            
        //}


        //public bool PreferenceDelete(int id)
        //{
        //    bool retVal = true;
            
        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {
        //            var para = new DynamicParameters();
        //            para.Add("@p_Id", id, dbType: DbType.Int32);
        //            conn.Execute("dbo.OXO_Preference_Delete", para, commandType: CommandType.StoredProcedure);                   
        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("OXOPreferenceDataStore.PreferenceDelete", ex.Message, CurrentCDSID);
        //            retVal = false;
        //        }
        //    }

        //    return retVal;
        //}    
    }
}
