using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using FeatureDemandPlanning.Controllers;
using FluentSecurity;

namespace FeatureDemandPlanning
{
    public static class SecurityHelper
    {
        public static void SetupRoles()
        {
            SecurityConfigurator.Configure(configuration =>
            {
                configuration.GetAuthenticationStatusFrom(IsUserAuthenticated);
                configuration.GetRolesFrom(GetUserRoles);

                configuration.ResolveServicesUsing(type =>
                {
                    if (type == typeof (IPolicyViolationHandler))
                    {
                        return new List<IPolicyViolationHandler>()
                        {
                            new RequireAnyRolePolicyViolationHandler(),
                            new DefaultSecurityPolicyViolationHandler()
                        };
                    }
                    return Enumerable.Empty<object>();
                });

                // Default policy with a friendly handler for all controllers, just in case we forget to implement something
                configuration.ForAllControllers()
                    .AddPolicy<DefaultSecurityPolicy>();

                configuration.For<HomeController>()
                    .DenyAnonymousAccess();

                configuration.For<AdminController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<UserController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator");

                //configuration.For<TakeRateController>()
                //    .RemovePolicy<DefaultSecurityPolicy>()
                //    .AddPolicy<HasAccessToMarketPolicy>()
                //    .AddPolicy<HasAccessToProgrammePolicy>();

                //configuration.For<TakeRateDataController>()
                //    .RemovePolicy<DefaultSecurityPolicy>()
                //    .AddPolicy<HasAccessToMarketPolicy>()
                //    .AddPolicy<HasAccessToProgrammePolicy>();
            });
            GlobalFilters.Filters.Add(new HandleSecurityAttribute(), 0);
        }

        public static bool IsUserAuthenticated()
        {
            return HttpContext.Current.User.Identity.IsAuthenticated;
        }

        public static string[] GetUserRoles()
        {
            return Roles.GetRolesForUser(HttpContext.Current.User.Identity.Name);
        }
    }
}