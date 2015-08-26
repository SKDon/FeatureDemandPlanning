
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Helpers;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.DataStore
{
    public class ModelTransmissionDataStore: DataStoreBase
    {
    
        public ModelTransmissionDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<ModelTransmission> ModelTransmissionGetMany
        (
            	     
        )
        {
            IEnumerable<ModelTransmission> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					    
					retVal = conn.Query<ModelTransmission>("dbo.OXO_ModelTransmission_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					AppHelper.LogError("ModelTransmissionDataStore.ModelTransmissionGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
        }

        public ModelTransmission ModelTransmissionGet(int id)
        {
            ModelTransmission retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<ModelTransmission>("dbo.OXO_ModelTransmission_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
				   AppHelper.LogError("ModelTransmissionDataStore.ModelTransmissionGet", ex.Message, CurrentCDSID);
				}
			}

            return retVal;
        }

        public bool ModelTransmissionSave(ModelTransmission obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_ModelTransmission_New" : "dbo.OXO_ModelTransmission_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    obj.Save(this.CurrentCDSID);

					var para = new DynamicParameters();          
					para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
					para.Add("@p_Type", obj.Type, dbType: DbType.String, size: 50);
					para.Add("@p_Drivetrain", obj.Drivetrain, dbType: DbType.String, size: 50);
					para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
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
					AppHelper.LogError("ModelTransmissionDataStore.ModelTransmissionSave", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
            
        }


        public bool ModelTransmissionDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					conn.Execute("dbo.OXO_ModelTransmission_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
					AppHelper.LogError("ModelTransmissionDataStore.ModelTransmissionDelete", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
        }
    }
}