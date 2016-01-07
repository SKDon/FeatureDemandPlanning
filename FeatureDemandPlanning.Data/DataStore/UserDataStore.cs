using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class UserDataStore : DataStoreBase
    {
        public UserDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }
        public User FdpUserSave(User userToAdd)
        {
            User retVal = new EmptyUser();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToAdd.CDSId, DbType.String);
                    para.Add("@FullName", userToAdd.FullName, DbType.String);
                    para.Add("@IsAdmin", userToAdd.IsAdmin, DbType.Boolean);
                    para.Add("@CreatorCDSId", CurrentCDSID, DbType.String);
                    
                    var results = conn.Query<User>("dbo.Fdp_User_Save", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<User> ?? results.ToList();
                    if (enumerable.Any()) {
                        retVal = enumerable.First();
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
                user = new User
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
                        para.Add("@CDSId", filter.CDSId, DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, DbType.String);
                    }
                    if (filter.HideInactiveUsers.HasValue)
                    {
                        para.Add("@HideInactiveUsers", filter.HideInactiveUsers, DbType.Boolean);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, DbType.Int32);
                    }
                    if (filter.SortDirection != SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
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
                    retVal = new PagedResults<User>
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
                    para.Add("@CDSId", userToEnable.CDSId, DbType.String);
                    para.Add("@IsActive", true, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

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
                    para.Add("@CDSId", userToDisable.CDSId, DbType.String);
                    para.Add("@IsActive", false, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

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
                    para.Add("@CDSId", userToSet.CDSId, DbType.String);
                    para.Add("@IsAdmin", true, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

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
                    para.Add("@CDSId", userToUnset.CDSId, DbType.String);
                    para.Add("@IsAdmin", false, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

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