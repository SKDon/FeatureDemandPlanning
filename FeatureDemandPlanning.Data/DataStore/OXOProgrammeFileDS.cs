using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class OXOProgrammeFileDataStore: DataStoreBase
    {
    
        public OXOProgrammeFileDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<OXOProgrammeFile> OXOProgrammeFileGetMany(int? progid,string category = null)
        {
            IEnumerable<OXOProgrammeFile> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();

                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_category", category, dbType: DbType.String, size: 100);					    
					retVal = conn.Query<OXOProgrammeFile>("dbo.OXO_Programme_File_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					AppHelper.LogError("OXOProgrammeFileDataStore.OXOProgrammeFileGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
        }

        public OXOProgrammeFile OXOProgrammeFileGet(int id)
        {
            OXOProgrammeFile retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					retVal = conn.Query<OXOProgrammeFile>("dbo.OXO_Programme_File_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
				   AppHelper.LogError("OXOProgrammeFileDataStore.OXOProgrammeFileGet", ex.Message, CurrentCDSID);
				}
			}

            return retVal;
        }

        public bool OXOProgrammeFileSave(OXOProgrammeFile obj)
        {
            bool retVal = true;
            string procName = (obj.Id == 0 ? "dbo.OXO_Programme_File_New" : "dbo.OXO_Programme_File_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{

                    obj.Save(this.CurrentCDSID);
                    
                    var para = new DynamicParameters();

                     para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
                     para.Add("@p_File_Category", obj.FileCategory, dbType: DbType.String, size: 100);
                     para.Add("@p_File_Comment", obj.FileComment, dbType: DbType.String, size: 2000);                    
                     para.Add("@p_File_Name", obj.FileName, dbType: DbType.String, size: 100);
                     para.Add("@p_File_Ext", obj.FileExt, dbType: DbType.String, size: 4);
					 para.Add("@p_File_Type", obj.FileType, dbType: DbType.String, size: 20);
					 para.Add("@p_File_Size", obj.FileSize, dbType: DbType.Int32);
                     para.Add("@p_gateway", obj.Gateway, dbType: DbType.String, size: 100);
                     para.Add("@p_PACN", obj.PACN, dbType: DbType.String, size: 10);					
					 para.Add("@p_File_Content", obj.FileContent, dbType: DbType.Binary);
					 para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
					 para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
					 para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
					 para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
					    

					if (obj.Id == 0)
					{
						para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.Output);
					}
					else
					{
						para.Add("@p_Id", obj.Id, dbType: DbType.Int32);
					}

					conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

					if (obj.Id == 0)
					{
						obj.Id = para.Get<int>("@p_Id");
					}

				}
				catch (Exception ex)
				{
					AppHelper.LogError("OXOProgrammeFileDataStore.OXOProgrammeFileSave", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
            
        }


        public bool OXOProgrammeFileDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					conn.Execute("dbo.OXO_Programme_File_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
					AppHelper.LogError("OXOProgrammeFileDataStore.OXOProgrammeFileDelete", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
        }
    }
}