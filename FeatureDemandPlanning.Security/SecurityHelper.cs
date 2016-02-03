using System;
using System.Web;
using System.Web.Security;

namespace FeatureDemandPlanning.Security
{
    public static class SecurityHelper
    {
        public static bool IsUserAuthenticated()
        {
            return HttpContext.Current.User.Identity.IsAuthenticated;
        }

        public static string[] GetUserRoles()
        {
            return Roles.GetRolesForUser(HttpContext.Current.User.Identity.Name);
        }

        public static string GetAuthenticatedUser()
        {
            return ParseUserName(HttpContext.Current.User.Identity.Name);
        }

        public static string ParseUserName(string userName)
        {
            var retVal = userName;
            if (userName.Contains(@"\"))
            {
                retVal = userName.Substring(userName.LastIndexOf(@"\", StringComparison.OrdinalIgnoreCase) + 1);
            }
            return retVal;
        }
    }
    
}
