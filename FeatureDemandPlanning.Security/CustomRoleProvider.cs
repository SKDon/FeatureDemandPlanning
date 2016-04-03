using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Security
{
    public class CustomRoleProvider : RoleProvider
    {
        public CustomRoleProvider()
        {
            context = DependencyResolver.Current.GetService<IDataContext>();
        }
        public override string[] GetRolesForUser(string userName)
        {
            Log.Debug(string.Format("HttpContext.User.Identity.Name:{0}", HttpContext.Current.User.Identity.Name));
            Log.Debug(string.Format("userName:{0}", userName));

            var authenticatedUser = context.User.GetUser();

            Log.Debug(string.Format("Roles:{0}", authenticatedUser.Roles.Select(r => Enum.GetName(r.GetType(), r)).ToCommaSeperatedList()));

            var retVal = authenticatedUser.Roles.Select(r => Enum.GetName(r.GetType(), r)).ToArray();
            return retVal;
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
        public override bool IsUserInRole(string userName, string roleName)
        {
            //IDataContext context = new DataContext(SecurityHelper.ParseUserName(userName));
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

        private readonly IDataContext context;
        private static readonly Logger Log = Logger.Instance;
    }
}