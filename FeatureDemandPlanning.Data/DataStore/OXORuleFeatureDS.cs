

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
    public class RuleFeatureDataStore: DataStoreBase
    {
    
        public RuleFeatureDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<RuleFeature> RuleFeatureGetMany(int id)
        {   
            IEnumerable<RuleFeature> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@p_rule_id", id, dbType: DbType.Int32);

                    retVal = conn.Query<RuleFeature>("dbo.OXO_Rule_Feature_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("RuleFeatureDataStore.RuleFeatureGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public bool OXORuleFeatureSave(RuleFeature obj, IDbConnection conn)
        {
            bool retVal = true;
            string procName = "dbo.OXO_Rule_Feature_New";

            try
            {

                obj.Save(this.CurrentCDSID);

                var para = new DynamicParameters();

                para.Add("@p_RuleId", obj.RuleId, dbType: DbType.Int32);
                para.Add("@p_ProgrammeId", obj.ProgrammeId, dbType: DbType.Int32);
                para.Add("@p_FeatureId", obj.FeatureId, dbType: DbType.Int32);
                para.Add("@p_CreatedBy", obj.CreatedBy, dbType: DbType.String, size: 8);
                para.Add("@p_CreatedOn", obj.CreatedOn, dbType: DbType.DateTime);
                para.Add("@p_UpdatedBy", obj.UpdatedBy, dbType: DbType.String, size: 8);
                para.Add("@p_LastUpdated", obj.LastUpdated, dbType: DbType.DateTime);

                conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

            }
            catch (Exception ex)
            {
                AppHelper.LogError("RuleFeatureDataStore.RuleFeatureSave", ex.Message, CurrentCDSID);
                retVal = false;
            }

            return retVal;

        }

    }
}