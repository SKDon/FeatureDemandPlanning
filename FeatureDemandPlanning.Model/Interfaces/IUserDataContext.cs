using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IUserDataContext
    {
        Task<User> AddUser(User userToAdd);
        Task<User> EnableUser(User userToEnable);
        Task<User> DisableUser(User userToDisable);
        Task<User> SetAdministrator(User userToSet);
        Task<User> UnsetAdministrator(User userToUnset);

        User GetUser();
        Task<User> GetUser(UserFilter filter);
        IEnumerable<Permission> ListPermissions();
        IEnumerable<NameValuePair> ListPreferences();
        IEnumerable<Programme> ListAllowedProgrammes();
        IEnumerable<Programme> ListAvailableProgrammes();

        Task<PagedResults<User>> ListUsers(UserFilter filter);
    }
}
