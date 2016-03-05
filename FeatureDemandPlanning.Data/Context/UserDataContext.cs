using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.DataStore
{
    public class UserDataContext : BaseDataContext, IUserDataContext
    {
        private readonly OXOPermissionDataStore _permissions;
        private readonly UserDataStore _userDataStore;

        public UserDataContext(string cdsId) : base(cdsId)
        {
            _permissions = new OXOPermissionDataStore(cdsId);
            _userDataStore = new UserDataStore(cdsId);
        }

        public async Task<User> AddUser(User userToAdd)
        {
            return await Task.FromResult(_userDataStore.FdpUserSave(userToAdd));
        }
        public async Task<User> EnableUser(User userToEnable)
        {
            return await Task.FromResult(_userDataStore.FdpUserEnable(userToEnable));
        }

        public async Task<User> DisableUser(User userToDisable)
        {
            return await Task.FromResult(_userDataStore.FdpUserDisable(userToDisable));
        }

        public async Task<User> SetAdministrator(User userToSet)
        {
            return await Task.FromResult(_userDataStore.FdpUserSetAdministrator(userToSet));
        }

        public async Task<User> UnsetAdministrator(User userToUnset)
        {
            return await Task.FromResult(_userDataStore.FdpUserUnSetAdministrator(userToUnset));
        }
        public User GetUser()
        {
            var user = _userDataStore.FdpUserGet(new UserFilter { CDSId = SecurityHelper.GetAuthenticatedUser()});
            user.Roles = _userDataStore.FdpUserGetRoles(user);
            user.Markets = _userDataStore.FdpUserMarketMappingsGetMany(user);
            user.Programmes = _userDataStore.FdpUserProgrammeMappingsGetMany(user);

            return user;
        }
        public async Task<User> GetUser(UserFilter filter)
        {
            var user = await Task.FromResult(_userDataStore.FdpUserGet(filter));
            user.Roles = _userDataStore.FdpUserGetRoles(user);
            user.Markets = _userDataStore.FdpUserMarketMappingsGetMany(user);
            user.Programmes = _userDataStore.FdpUserProgrammeMappingsGetMany(user);

            return user;
        }

        public async Task<PagedResults<UserDataItem>> ListUsers(UserFilter filter)
        {
            return await Task.FromResult(_userDataStore.FdpUserGetMany(filter));
        }

        public IEnumerable<Permission> ListPermissions()
        {
            return _permissions.PermissionGetMany(CDSID, null);
        }

        public IEnumerable<NameValuePair> ListPreferences()
        {
            yield return null;
        }

        public IEnumerable<Programme> ListAllowedProgrammes()
        {
            throw new NotImplementedException();
        }

        public IEnumerable<Programme> ListAvailableProgrammes()
        {
            throw new NotImplementedException();
        }


        public async Task<IEnumerable<UserProgrammeMapping>> AddProgramme(UserFilter filter)
        {
            var user = await GetUser(filter);

            var programmes = user.Programmes.ToList();
            var exists = programmes.Any(p => p.ProgrammeId == filter.ProgrammeId && p.Action == filter.RoleAction);
            if (!exists)
            {
                programmes.Add(new UserProgrammeMapping()
                {
                    FdpUserId = user.FdpUserId.GetValueOrDefault(), 
                    ProgrammeId = filter.ProgrammeId.GetValueOrDefault(), 
                    Action = filter.RoleAction
                });
            }
            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = programmes.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserProgrammeMappingsSave(filter));
        }

        public async Task<IEnumerable<UserProgrammeMapping>> RemoveProgramme(UserFilter filter)
        {
            var user = await GetUser(filter);

            var programmes = user.Programmes.ToList();
            var index = programmes.FindIndex(p => p.ProgrammeId == filter.ProgrammeId && p.Action == filter.RoleAction);
            if (index != -1)
                programmes.RemoveAt(index);
            
            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = programmes.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserProgrammeMappingsSave(filter));
        }

        public async Task<IEnumerable<UserMarketMapping>> AddMarket(UserFilter filter)
        {
            var user = await GetUser(filter);

            var markets = user.Markets.ToList();
            var exists = markets.Any(p => p.MarketId == filter.MarketId && p.Action == filter.RoleAction);
            if (!exists)
            {
                markets.Add(new UserMarketMapping()
                {
                    FdpUserId = user.FdpUserId.GetValueOrDefault(),
                    MarketId = filter.MarketId.GetValueOrDefault(),
                    Action = filter.RoleAction
                });
            }
            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = markets.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserMarketMappingsSave(filter));
        }

        public async Task<IEnumerable<UserMarketMapping>> RemoveMarket(UserFilter filter)
        {
            var user = await GetUser(filter);

            var markets = user.Markets.ToList();
            var index = markets.FindIndex(m => m.MarketId == filter.MarketId && m.Action == filter.RoleAction);
            if (index != -1)
                markets.RemoveAt(index);

            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = markets.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserMarketMappingsSave(filter));
        }

        public async Task<IEnumerable<UserRole>> AddRole(UserFilter filter)
        {
            var user = await GetUser(filter);

            var roles = user.Roles.ToList();
            var exists = roles.Any(r => r == filter.Role);
            if (!exists)
            {
                roles.Add(filter.Role);
            }
            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = roles.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserRolesSave(filter));
        }

        public async Task<IEnumerable<UserRole>> RemoveRole(UserFilter filter)
        {
            var user = await GetUser(filter);

            var roles = user.Roles.ToList();
            var index = roles.FindIndex(r => r == filter.Role);
            if (index != -1)
                roles.RemoveAt(index);

            // Build up a comma seperated list of programme ids and permissions
            filter.Permissions = roles.ToPermissionString();

            return await Task.FromResult(_userDataStore.FdpUserRolesSave(filter));
        }
    }
}
