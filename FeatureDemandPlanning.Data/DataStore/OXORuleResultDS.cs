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
    public class RuleResultDataStore: DataStoreBase
    {
    
        public RuleResultDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<OXORuleResult> RuleResultGetMany(int docid, int progid, string level, int objid, bool? showWhat)
        {
            IEnumerable<OXORuleResult> retVal = null;   
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();

                    para.Add("@p_oxo_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_Level", level, dbType: DbType.String, size: 3);
                    para.Add("@p_ObjectId", objid, dbType: DbType.Int32);
                    para.Add("@p_show_what", showWhat, dbType: DbType.Boolean);
					    
					retVal = conn.Query<OXORuleResult>("dbo.OXO_Programme_Rule_Result_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					AppHelper.LogError("RuleResultDataStore.RuleResultGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
        }

        public OXORuleResult RuleResultGet(int id)
        {
            OXORuleResult retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<OXORuleResult>("dbo.OXO_Programme_Rule_Result_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
				   AppHelper.LogError("RuleResultDataStore.RuleResultGet", ex.Message, CurrentCDSID);
				}
			}

            return retVal;
        }

        public bool RuleResultSave(OXORuleResult obj)
        {
            bool retVal = true;
            string procName = (obj.Id == 0 ? "dbo.OXO_Programme_Rule_Result_New" : "dbo.OXO_Programme_Rule_Result_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    obj.Save(this.CurrentCDSID);

					var para = new DynamicParameters();

					 para.Add("@p_OXODocId", obj.OXODocId, dbType: DbType.Int32);
					 para.Add("@p_ProgrammeId", obj.ProgrammeId, dbType: DbType.Int32);
                     para.Add("@p_Level", obj.ObjectLevel, dbType: DbType.String, size: 3);
                     para.Add("@p_ObjectId", obj.ObjectId, dbType: DbType.Int32);
					 para.Add("@p_RuleId", obj.RuleId, dbType: DbType.Int32);
					 para.Add("@p_ModelId", obj.ModelId, dbType: DbType.Int32);
					 para.Add("@p_RuleResult", obj.RuleResult, dbType: DbType.Boolean);
					 para.Add("@p_CreatedBy", obj.CreatedBy, dbType: DbType.String, size: 8);
					 para.Add("@p_CreatedOn", obj.CreatedOn, dbType: DbType.DateTime);
					    

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
					AppHelper.LogError("RuleResultDataStore.RuleResultSave", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
            
        }


        public bool RuleResultDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					conn.Execute("dbo.OXO_Programme_Rule_Result_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
					AppHelper.LogError("RuleResultDataStore.RuleResultDelete", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
        }


        public bool RuleResultDeleteProg(int docid, int progid, string level, int objid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_OXODocId", docid, dbType: DbType.Int32);
                    para.Add("@p_ProgrammeId", progid, dbType: DbType.Int32);
                    para.Add("@p_Level", level, dbType: DbType.String, size: 3);
                    para.Add("@p_ObjectId", objid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Rule_Result_DeleteProg", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("RuleResultDataStore.RuleResultDeleteProg", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }
    }
}