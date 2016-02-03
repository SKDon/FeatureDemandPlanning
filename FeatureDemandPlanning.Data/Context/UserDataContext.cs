using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
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
            var user = _userDataStore.FdpUserGet(new UserFilter { CDSId = CDSID});
            user.Roles = _userDataStore.FdpUserGetRoles(user);
            user.Markets = _userDataStore.FdpUserMarketMappingsGetMany(user);
            user.Programmes = _userDataStore.FdpUserProgrammeMappingsGetMany(user);

            return user;
        }
        public async Task<User> GetUser(UserFilter filter)
        {
            return await Task.FromResult(_userDataStore.FdpUserGet(filter));
        }

        public async Task<PagedResults<User>> ListUsers(UserFilter filter)
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
    }
}
