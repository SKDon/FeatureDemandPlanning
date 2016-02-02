using System;
using System.Linq;
using System.Web.Security;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning
{
    public class CustomRoleProvider : RoleProvider
    {
        public override string[] GetRolesForUser(string username)
        {
            IDataContext context = new DataContext(username);
            var authenticatedUser = context.User.GetUser();

            return authenticatedUser.Roles.Select(r => Enum.GetName(r.GetType(), r)).ToArray();
        }

        public override void CreateRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new NotImplementedException();
        }

        public override string[] FindUsersInRole(string roleName, string usernameToMatch)
        {
            throw new NotImplementedException();
        }

        public override string ApplicationName
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }
        public override bool IsUserInRole(string username, string roleName)
        {
            IDataContext context = new DataContext(username);
            var authenticatedUser = context.User.GetUser();

            return authenticatedUser.Roles.Any(r =>
            {
                var name = Enum.GetName(r.GetType(), r);
                return name != null && name.Equals(roleName);
            });
        }

        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override string[] GetUsersInRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override string[] GetAllRoles()
        {
            throw new NotImplementedException();
        }

        public override bool RoleExists(string roleName)
        {
            return true;
        }
    }
}