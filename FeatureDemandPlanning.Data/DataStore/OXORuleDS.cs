

using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class OXORuleDataStore: DataStoreBase
    {    
        public OXORuleDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<OXORule> OXORuleGetMany(int id)
        {
            IEnumerable<OXORule> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    var para = new DynamicParameters();
                    para.Add("@p_prog_Id", id, dbType: DbType.Int32);

                    retVal = conn.Query<OXORule>("dbo.OXO_Programme_Rule_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;   
        }

        public OXORule OXORuleGet(int id)
        {
            OXORule retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<OXORule>("dbo.OXO_Programme_Rule_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
        }

        public bool OXORuleSave(OXORule obj, Array aRuleFeats)
        {
            bool retVal = true;
            string procName = (obj.Id == 0 ? "dbo.OXO_Programme_Rule_New" : "dbo.OXO_Programme_Rule_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{

                    obj.Save(this.CurrentCDSID);

                    var para = new DynamicParameters();

					 para.Add("@p_ProgrammeId", obj.ProgrammeId, dbType: DbType.Int32);
					 para.Add("@p_RuleCategory", obj.RuleCategory, dbType: DbType.String, size: 50);
                     para.Add("@p_RuleGroup", obj.RuleGroup, dbType: DbType.String, size: 50);
					 para.Add("@p_RuleAssertLogic", obj.RuleAssertLogic, dbType: DbType.String, size: -1);
					 para.Add("@p_RuleReportLogic", obj.RuleReportLogic, dbType: DbType.String, size: -1);
					 para.Add("@p_RuleResponse", obj.RuleResponse, dbType: DbType.String, size: -1);
                     para.Add("@p_RuleReason", obj.RuleReason, dbType: DbType.String, size: -1);
					 para.Add("@p_Owner", obj.Owner, dbType: DbType.String, size: 50);
					 para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
					 para.Add("@p_CreatedBy", obj.CreatedBy, dbType: DbType.String, size: 8);
					 para.Add("@p_CreatedOn", obj.CreatedOn, dbType: DbType.DateTime);
					 para.Add("@p_UpdatedBy", obj.UpdatedBy, dbType: DbType.String, size: 8);
					 para.Add("@p_LastUpdated", obj.LastUpdated, dbType: DbType.DateTime);
					    

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

                    para = new DynamicParameters();
                    
                    procName = "dbo.OXO_Rule_Feature_Delete";

                    try
                    {
                        para.Add("@p_RuleId", obj.Id, dbType: DbType.Int32);
                        para.Add("@p_ProgrammeId", obj.ProgrammeId, dbType: DbType.Int32);

                        conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    }
                    catch (Exception ex)
                    {
                        Log.Error(ex);
                        throw;
                    }

                    procName = "dbo.OXO_Rule_Feature_New";

                    foreach (var item in aRuleFeats) {

                        para = new DynamicParameters();
                        
                        try
                        {

                            para.Add("@p_RuleId", obj.Id, dbType: DbType.Int32);
                            para.Add("@p_ProgrammeId", obj.ProgrammeId, dbType: DbType.Int32);
                            para.Add("@p_FeatureId", item, dbType: DbType.Int32);
                            para.Add("@p_CreatedBy", "pbriscoe", dbType: DbType.String, size: 8);
                            para.Add("@p_CreatedOn", DateTime.Now, dbType: DbType.DateTime);
                            para.Add("@p_UpdatedBy", obj.UpdatedBy, dbType: DbType.String, size: 8);
                            para.Add("@p_LastUpdated", obj.LastUpdated, dbType: DbType.DateTime);

                            conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                        }
                        catch (Exception ex)
                        {
                            Log.Error(ex);
                            throw;
                        }

                    }
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
            
        }

        public bool OXORuleDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Rule_Delete", para, commandType: CommandType.StoredProcedure);                   
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