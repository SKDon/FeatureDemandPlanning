using System.Web.Mvc;
using FeatureDemandPlanning.Controllers;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model.Parameters;
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

                //configuration.ResolveServicesUsing(type =>
                //{
                //    if (type == typeof (IPolicyViolationHandler))
                //    {
                //        return new List<IPolicyViolationHandler>()
                //        {
                //            new RequireAnyRolePolicyViolationHandler(),
                //            new DefaultSecurityPolicyViolationHandler(),
                //            new HasAccessToMarketPolicyViolationHandler(),
                //            new HasAccessToProgrammePolicyViolationHandler()
                //        };
                //    }
                //    return Enumerable.Empty<object>();
                //});

                configuration.ResolveServicesUsing(DependencyResolver.Current.GetServices, DependencyResolver.Current.GetService);


                // Default policy with a friendly handler for all controllers, just in case we forget to implement something
                configuration.ForAllControllers()
                    .AddPolicy<DefaultSecurityPolicy>();

                configuration.For<HomeController>()
                    .DenyAnonymousAccess();

                configuration.For<ImportController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<ImportController>(i => i.DeleteImport(new ImportParameters()))
                    .RequireAnyRole("CanDelete");

                configuration.For<ImportExceptionController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<AdminController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<UserController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator");

                configuration.For<UserController>(x => x.MyAccount())
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("User");

                // My user account needs to allow all users access
                configuration.ForActionsMatching(
                    a => a.ControllerType == typeof(UserController) && a.ActionName.Equals("MyAccount"))
                    .Ignore();

                configuration.For<TakeRateController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>();

                configuration.For<TakeRateController>(t => t.Clone(new TakeRateParameters()))
                    .RequireAnyRole("Cloner");
               

                configuration.For<TakeRateDataController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>();

                configuration.For<MarketReviewController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>()
                    .RequireAnyRole("Administrator", "Editor", "MarketReviewer");

                configuration.For<PublishController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .AddPolicy<HasAccessToMarketPolicy>()
                    .AddPolicy<HasAccessToProgrammePolicy>()
                    .RequireAnyRole("Administrator", "Editor", "Publisher");

                configuration.For<DerivativeController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");
                
                configuration.For<DerivativeMappingController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<TrimController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<TrimMappingController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<FeatureController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<FeatureMappingController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<MarketController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<MarketMappingController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<IgnoredExceptionController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<SpecialFeatureMappingController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("Administrator", "Importer");

                configuration.For<NewsController>()
                    .RemovePolicy<DefaultSecurityPolicy>()
                    .RequireAnyRole("User");
            });
            GlobalFilters.Filters.Add(new HandleSecurityAttribute(), 0);
        }
    }
}
