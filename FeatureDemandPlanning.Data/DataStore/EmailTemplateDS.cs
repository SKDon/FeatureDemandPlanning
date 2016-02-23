using System;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class EmailTemplateDataStore : DataStoreBase
    {
        public EmailTemplateDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }
        public EmailTemplate EmailTemplateGet(EmailEvent emailEvent)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                EmailTemplate retVal;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpEmailTemplateId", (int)emailEvent, DbType.Int32);
                    retVal = conn.Query<EmailTemplate>("dbo.Fdp_EmailTemplate_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

                return retVal;
            }
        }
    }
}