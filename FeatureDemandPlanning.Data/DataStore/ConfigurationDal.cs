
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 28/07/2015 12:13  
 * 
 *===============================================================================
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class ConfigurationDataStore: DataStoreBase
    {
    
        public ConfigurationDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }

        public IEnumerable<ConfigurationItem> ConfigurationGetMany()
        {
            IEnumerable<ConfigurationItem> retVal = null;
			using (var conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					    
					retVal = conn.Query<ConfigurationItem>("dbo.Fdp_Configuration_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					Log.Error(ex);
				    throw;
				}
			}

            return retVal;   
        }

        public ConfigurationItem ConfigurationGet(string key)
        {
            ConfigurationItem retVal = null;

			using (var conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_ConfigurationKey", key, DbType.String);
					retVal = conn.Query<ConfigurationItem>("dbo.Fdp_Configuration_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
                {
				    Log.Error(ex);
                    throw;
                }
			}

            return retVal;
        }

        public bool ConfigurationSave(ConfigurationItem obj)
        {
            var retVal = true;
            const string procName = "dbo.Fdp_Configuration_Edit";

			using (var conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();

					 para.Add("@p_ConfigurationKey", obj.ConfigurationKey, DbType.String, size: 50);
					 para.Add("@p_Value", obj.Value, DbType.String, size: -1);
					 para.Add("@p_Description", obj.Description, DbType.String, size: -1);
                     para.Add("@p_DataType", obj.DataType, DbType.String, size: 50);

					conn.Execute(procName, para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
            
        }


        public bool ConfigurationDelete(string key)
        {
            var retVal = true;
            
			using (var conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_ConfigurationKey", key, DbType.String);
					conn.Execute("dbo.Fdp_Configuration_Delete", para, commandType: CommandType.StoredProcedure);                   
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