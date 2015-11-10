using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class UserDataContext : BaseDataContext, IUserDataContext
    {
        private OXOPermissionDataStore _permissions = null;
        private UserDataStore _userDataStore = null;
        private ReferenceListDataStore _referenceListDataStore = null;
        
        public UserDataContext(string cdsId) : base(cdsId)
        {
            _permissions = new OXOPermissionDataStore(cdsId);
            _userDataStore = new UserDataStore(cdsId);
            _referenceListDataStore = new ReferenceListDataStore(cdsId);
        }

        public async Task<User> AddUser(User userToAdd)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserSave(userToAdd));
        }
        public async Task<User> EnableUser(User userToEnable)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserEnable(userToEnable));
        }

        public async Task<User> DisableUser(User userToDisable)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserDisable(userToDisable));
        }

        public async Task<User> SetAdministrator(User userToSet)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserSetAdministrator(userToSet));
        }

        public async Task<User> UnsetAdministrator(User userToUnset)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserUnSetAdministrator(userToUnset));
        }
        public async Task<User> GetUser()
        {
            return await GetUser(new UserFilter() { CDSId = CDSID });
        }
        public async Task<User> GetUser(UserFilter filter)
        {
            return await Task.FromResult<User>(_userDataStore.FdpUserGet(filter));
        }

        public async Task<PagedResults<User>> ListUsers(UserFilter filter)
        {
            return await Task.FromResult<PagedResults<User>>(_userDataStore.FdpUserGetMany(filter));
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
