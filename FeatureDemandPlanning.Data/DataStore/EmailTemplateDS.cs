using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;

namespace FeatureDemandPlanning.DataStore
{
    public class EmailTemplateDS : DataStoreBase
    {
        public EmailTemplateDS(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        private const string C_SP_EMT_GETMANY = "dbo.USP_VBR_EMT_GETMANY";
        private const string C_SP_EMT_GET = "dbo.USP_VBR_EMT_GET";
        private const string C_SP_EMT_NEW = "dbo.USP_VBR_EMT_NEW";
        private const string C_SP_EMT_EDIT = "dbo.USP_VBR_EMT_EDIT";

        public IEnumerable<EmailTemplate> EmailTemplateGetMany()
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<EmailTemplate> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<EmailTemplate>(C_SP_EMT_GETMANY, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("EmailTemplateDS.EmailTemplateGetMany", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }

        public EmailTemplate EmailTemplateGet(string emailEvent)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                EmailTemplate retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_event", emailEvent, dbType: DbType.String, size: 50);
                    retVal = conn.Query<EmailTemplate>(C_SP_EMT_GET, para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("EmailTemplateDS.EmailTemplateGet", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }

        public bool EmailTemplateSave(EmailTemplate template)
        {
            bool retVal = true;
            string procName = (template.IsNew ? C_SP_EMT_NEW : C_SP_EMT_EDIT);

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();


                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    if (template.IsNew)
                    {
                        template.Id = para.Get<int>("@p_Id");
                    }

                }
                catch (Exception ex)
                {
                    AppHelper.LogError("EmailTemplateDS.EmailTemplateSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }

                return retVal;
            }
        }

    }
}