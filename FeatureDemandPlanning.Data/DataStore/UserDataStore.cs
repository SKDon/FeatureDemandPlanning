using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FeatureDemandPlanning.Model;
using System.Data;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Dapper;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.DataStore
{
    public class UserDataStore : DataStoreBase
    {
        public UserDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }
        public User FdpUserSave(User userToAdd)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToAdd.CDSId, dbType: DbType.String);
                    para.Add("@FullName", userToAdd.FullName, dbType: DbType.String);
                    para.Add("@IsAdmin", userToAdd.IsAdmin, dbType: DbType.Boolean);
                    para.Add("@CreatorCDSId", this.CurrentCDSID, dbType: DbType.String);
                    
                    var results = conn.Query<User>("dbo.Fdp_User_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any()) {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.FdpUserSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }
        public User FdpUserGet(UserFilter filter)
        {
            User user;
            var results = FdpUserGetMany(filter);
            if (results.CurrentPage.Any())
            {
                user = results.CurrentPage.First();
            }
            else
            {
                user = new User()
                {
                    CDSId = filter.CDSId
                };
            }
            return user;
        }

        public PagedResults<User> FdpUserGetMany(UserFilter filter)
        {
            PagedResults<User> retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (!string.IsNullOrEmpty(filter.CDSId))
                    {
                        para.Add("@CDSId", filter.CDSId, dbType: DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, dbType: DbType.String);
                    }
                    if (filter.HideInactiveUsers.HasValue)
                    {
                        para.Add("@HideInactiveUsers", filter.HideInactiveUsers, dbType: DbType.Boolean);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, dbType: DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.SortDirection != Model.Enumerations.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == Model.Enumerations.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, dbType: DbType.String);
                    }
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<User>("dbo.Fdp_User_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<User>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<User>();

                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }

                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SysteUserDS.FdpUserGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }
        public User FdpUserEnable(User userToEnable)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToEnable.CDSId, dbType: DbType.String);
                    para.Add("@IsActive", true, dbType: DbType.Boolean);
                    para.Add("@UpdatedByCDSId", this.CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<User>("dbo.Fdp_User_SetIsActive", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.FdpUserEnable", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public User FdpUserDisable(User userToDisable)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToDisable.CDSId, dbType: DbType.String);
                    para.Add("@IsActive", false, dbType: DbType.Boolean);
                    para.Add("@UpdatedByCDSId", this.CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<User>("dbo.Fdp_User_SetIsActive", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.FdpUserDisable", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public User FdpUserSetAdministrator(User userToSet)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToSet.CDSId, dbType: DbType.String);
                    para.Add("@IsAdmin", true, dbType: DbType.Boolean);
                    para.Add("@UpdatedByCDSId", this.CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<User>("dbo.Fdp_User_SetIsAdmin", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.FdpUserSetAdministrator", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public User FdpUserUnSetAdministrator(User userToUnset)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToUnset.CDSId, dbType: DbType.String);
                    para.Add("@IsAdmin", false, dbType: DbType.Boolean);
                    para.Add("@UpdatedByCDSId", this.CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<User>("dbo.Fdp_User_SetIsAdmin", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("SystemUserDS.FdpUserUnSetAdministrator", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }

}