using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using FeatureDemandPlanning.Controllers;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public static class FluentSecurityHelper
    {
        public static void SetupRoles()
        {
            SecurityConfigurator.Configure(configuration =>
            {
                configuration.GetAuthenticationStatusFrom(SecurityHelper.IsUserAuthenticated);
                configuration.GetRolesFrom(SecurityHelper.GetUserRoles);

                configuration.ResolveServicesUsing(type =>
                {
                    if (type == typeof (IPolicyViolationHandler))
                    {
                        return new List<IPolicyViolationHandler>()
                        {
                            new RequireAnyRolePolicyViolationHandler(),
                            new DefaultSecurityPolicyViolationHandler(),
                            new HasAccessToMarketPolicyViolationHandler(),
                            new HasAccessToProgrammePolicyViolationHandler()
                        };
                    }
                    return Enumerable.Empty<object>();
                });

                // Default policy with a friendly handler for all controllers, just in case we forget to implement something
                configuration.ForAllControllers()
                    .AddPolicy<DefaultSecurityPolicy>();

                configuration.For<HomeController>()
                    .DenyAnonymousAccess();

                configuration.For<ImportController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<ImportExceptionController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<AdminController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<UserController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator");

                // My user account needs to allow all users access
                configuration.ForActionsMatching(
                    a => a.ControllerType == typeof (UserController) && a.ActionName.Equals("MyAccount"))
                    .Ignore();

                configuration.For<TakeRateController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>();

                configuration.For<TakeRateDataController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>();

                //configuration.ForAllControllers().Ignore();
            });
            GlobalFilters.Filters.Add(new HandleSecurityAttribute(), 0);
        }
    }
}