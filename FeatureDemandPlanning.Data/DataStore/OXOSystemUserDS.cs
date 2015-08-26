using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FeatureDemandPlanning.BusinessObjects;
using System.Data;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Dapper;

namespace FeatureDemandPlanning.DataStore
{
    public class SystemUserDataStore : DataStoreBase
    {
        public SystemUserDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }
       
        public IEnumerable<SystemUser> SystemUserGetMany(string department, string surname)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<SystemUser> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_department", department, dbType: DbType.String, size: 10);
                    para.Add("@p_surname", surname + "%", dbType: DbType.String, size: 10);
                    retVal = conn.Query<SystemUser>("dbo.OXO_SysUser_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.SystemUserGetMany", ex.Message, CurrentCDSID);
                }

                return retVal;
            }
        }

        public SystemUser SystemUserGet(int id)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                SystemUser retVal = null;

                if (id != 0)
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@p_id", id, dbType: DbType.Int32);
                        
                        retVal = conn.Query<SystemUser>("dbo.OXO_SysUser_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("SystemUserDS.SystemUserGet", ex.Message, CurrentCDSID);
                    }
                }

                return retVal;
            }
        }

        public SystemUser SystemUserGet(string cdsid)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                SystemUser retVal = null;

                if (cdsid != null)
                {
                    try
                    {
                        var para = new DynamicParameters();
                        para.Add("@p_cdsid", cdsid, dbType: DbType.String, size:50);

                        retVal = conn.Query<SystemUser>("dbo.OXO_SysUser_GetByCDSID", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                    }
                    catch (Exception ex)
                    {
                        AppHelper.LogError("SystemUserDS.SystemUserGet", ex.Message, CurrentCDSID);
                    }
                }

                return retVal;
            }
        }

        public bool SystemUserSave(SystemUser user)
        {
            bool retVal = true;
            string procName = (user.IsNew ? "dbo.OXO_SysUser_New" : "dbo.OXO_SysUser_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@p_cdsid", user.CDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_title", user.Title, dbType: DbType.String, size: 50);
                    para.Add("@p_first_names", user.Firstnames, dbType: DbType.String, size: 100);
                    para.Add("@p_surname", user.Surname, dbType: DbType.String, size: 100);
                    para.Add("@p_department", user.Department, dbType: DbType.String, size: 100);
                    para.Add("@p_job_title", user.JobTitle, dbType: DbType.String, size: 100);
                    para.Add("@p_senior_mgr", user.SeniorManager, dbType: DbType.String, size: 300);
                    para.Add("@p_allowed_progs", user.AllowedProgrammeString, dbType: DbType.String, size: 3000);
                    para.Add("@p_allowed_sections", user.AllowedSectionString, dbType: DbType.String, size: 3000);
                    para.Add("@p_admin", user.IsAdmin, DbType.Boolean);
                    para.Add("@p_Id", user.Id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);  	
                    
                    if (user.IsNew)
                    {
                        para.Add("@p_created_by", user.CDSID, dbType: DbType.String, size: 10);
                    }
                    else
                    {
                        para.Add("@p_registered_on", user.RegisteredOn, dbType: DbType.DateTime);
                        para.Add("@p_updated_by", user.CDSID, dbType: DbType.String, size: 10);
                    }
                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    user.Id = para.Get<int>("@p_Id");

                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.SystemUserSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }

                return retVal;
            }
        }
        
        public bool SystemUserDelete(int id)
        {
            bool retVal = true;
            string procName = "dbo.OXO_SysUser_Delete";

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_id", id, dbType: DbType.Int32);
                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.SystemUserDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }

                return retVal;
            }
        }

        public IEnumerable<Programme> SystemUserProgrammes(string cdsid, bool allowed)
        {
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                IEnumerable<Programme> retVal = null;
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_CDSID", cdsid, dbType: DbType.String, size: 10);
                    para.Add("@p_allowed", allowed, dbType: DbType.Boolean);
                    retVal = conn.Query<Programme>("dbo.OXO_SysUser_GetProgrammes", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.SystemUserProgrammes", ex.Message, CurrentCDSID);
                }

                return retVal;
            }

        }

    }

}