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

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToAdd.CDSId, DbType.String);
                    para.Add("@FullName", userToAdd.FullName, DbType.String);
                    para.Add("@Mail", userToAdd.Mail, DbType.String);
                    para.Add("@IsAdmin", userToAdd.IsAdmin, DbType.Boolean);
                    para.Add("@CreatorCDSId", CurrentCDSID, DbType.String);
                    
                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_Save", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any()) {
                        retVal = enumerable.First().ToUser();
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
        public User FdpUserGet(UserFilter filter)
        {
            User user;
            var results = FdpUserGetMany(filter);
            if (results.CurrentPage.Any())
            {
                user = results.CurrentPage.First().ToUser();
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
        public IEnumerable<UserRole> FdpUserGetRoles(User forUser)
        {
            IList<UserRole> retVal = new List<UserRole>{UserRole.None};
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", forUser.CDSId, DbType.String);
                   
                    var results = conn.Query<FdpUserRoleDataItem>("dbo.Fdp_UserRole_GetMany", para, commandType: CommandType.StoredProcedure);
                    var fdpUserRoleDataItems = results as IList<FdpUserRoleDataItem> ?? results.ToList();
                    if (fdpUserRoleDataItems.Any())
                    {
                        retVal = fdpUserRoleDataItems.Select(role => (UserRole) role.FdpUserRoleId).ToList();
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
        public IEnumerable<UserMarketMapping> FdpUserMarketMappingsGetMany(User forUser)
        {
            IEnumerable<UserMarketMapping> retVal;
            
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", forUser.CDSId, DbType.String);

                    retVal = conn.Query<UserMarketMapping>("dbo.Fdp_UserMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public IEnumerable<UserProgrammeMapping> FdpUserProgrammeMappingsGetMany(User forUser)
        {
            IEnumerable<UserProgrammeMapping> retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", forUser.CDSId, DbType.String);

                    retVal = conn.Query<UserProgrammeMapping>("dbo.Fdp_UserProgramme_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        } 
        public PagedResults<UserDataItem> FdpUserGetMany(UserFilter filter)
        {
            PagedResults<UserDataItem> retVal;

            using (var conn = DbHelper.GetDBConnection())
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
                        para.Add("@PageSize", filter.PageSize.Value, DbType.Int32);
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

                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_GetMany", para, commandType: CommandType.StoredProcedure);

                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<UserDataItem>
                    {
                        PageIndex = filter.PageIndex ?? 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize ?? totalRecords
                    };

                    var currentPage = enumerable.ToList();

                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public User FdpUserEnable(User userToEnable)
        {
            User retVal = new EmptyUser();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToEnable.CDSId, DbType.String);
                    para.Add("@IsActive", true, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_SetIsActive", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        retVal = enumerable.First().ToUser();
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
        public User FdpUserDisable(User userToDisable)
        {
            User retVal = new EmptyUser();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToDisable.CDSId, DbType.String);
                    para.Add("@IsActive", false, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_SetIsActive", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        retVal = enumerable.First().ToUser();
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
        public User FdpUserSetAdministrator(User userToSet)
        {
            User retVal = new EmptyUser();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToSet.CDSId, DbType.String);
                    para.Add("@IsAdmin", true, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_SetIsAdmin", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        retVal = enumerable.First().ToUser();
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
        public User FdpUserUnSetAdministrator(User userToUnset)
        {
            User retVal = new EmptyUser();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", userToUnset.CDSId, DbType.String);
                    para.Add("@IsAdmin", false, DbType.Boolean);
                    para.Add("@UpdatedByCDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<UserDataItem>("dbo.Fdp_User_SetIsAdmin", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<UserDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        retVal = enumerable.First().ToUser();
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

        private class FdpUserRoleDataItem
        {
            public int FdpUserRoleId  { get; set; }
            public string Role { get; set; }
            public string Description { get; set; }
        }

        public IEnumerable<UserProgrammeMapping> FdpUserProgrammeMappingsSave(UserFilter filter)
        {
            IEnumerable<UserProgrammeMapping> retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", filter.CDSId, DbType.String);
                    para.Add("@ProgrammeIds", filter.Permissions, DbType.String);
                    para.Add("@CreatorCDSId", CurrentCDSID, DbType.String);

                    retVal = conn.Query<UserProgrammeMapping>("dbo.Fdp_UserProgrammes_Save", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<UserMarketMapping> FdpUserMarketMappingsSave(UserFilter filter)
        {
            IEnumerable<UserMarketMapping> retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", filter.CDSId, DbType.String);
                    para.Add("@MarketIds", filter.Permissions, DbType.String);
                    para.Add("@CreatorCDSId", CurrentCDSID, DbType.String);

                    retVal = conn.Query<UserMarketMapping>("dbo.Fdp_UserMarkets_Save", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<UserRole> FdpUserRolesSave(UserFilter filter)
        {
            var retVal = Enumerable.Empty<UserRole>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@CDSId", filter.CDSId, DbType.String);
                    para.Add("@RoleIds", filter.Permissions, DbType.String);
                    para.Add("@CreatorCDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpUserRoleDataItem>("dbo.Fdp_UserRoles_Save", para, commandType: CommandType.StoredProcedure);
                    var enumerable = results as IList<FdpUserRoleDataItem> ?? results.ToList();
                    if (enumerable.Any())
                    {
                        retVal = enumerable.Select(r => (UserRole) r.FdpUserRoleId);
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
    }
}