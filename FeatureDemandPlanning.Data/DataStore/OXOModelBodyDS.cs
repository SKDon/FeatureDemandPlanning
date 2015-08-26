
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.DataStore;

namespace FeatureDemandPlanning.DataStore
{
    public class ModelBodyDataStore: DataStoreBase
    {
    
        public ModelBodyDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<ModelBody> ModelBodyGetMany
        (
            	     
        )
        {
            IEnumerable<ModelBody> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					    
					retVal = conn.Query<ModelBody>("dbo.OXO_ModelBody_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					AppHelper.LogError("ModelBodyDataStore.ModelBodyGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
        }

        public ModelBody ModelBodyGet(int id)
        {
            ModelBody retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					retVal = conn.Query<ModelBody>("dbo.OXO_ModelBody_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
				   AppHelper.LogError("ModelBodyDataStore.ModelBodyGet", ex.Message, CurrentCDSID);
				}
			}

            return retVal;
        }

        public bool ModelBodySave(ModelBody obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_ModelBody_New" : "dbo.OXO_ModelBody_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    obj.Save(this.CurrentCDSID);
   
                    var para = new DynamicParameters();
                    para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@p_Shape", obj.Shape, dbType: DbType.String, size: 50);
                    para.Add("@p_Doors", obj.Doors, dbType: DbType.String, size: 50);
                    para.Add("@p_Wheelbase", obj.Wheelbase, dbType: DbType.String, size: 50);
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
					AppHelper.LogError("ModelBodyDataStore.ModelBodySave", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
            
        }


        public bool ModelBodyDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					conn.Execute("dbo.OXO_ModelBody_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
					AppHelper.LogError("ModelBodyDataStore.ModelBodyDelete", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
        }
    }
}