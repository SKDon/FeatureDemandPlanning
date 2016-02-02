using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using FeatureDemandPlanning.Model.Attributes;
using FluentValidation.Mvc;

namespace FeatureDemandPlanning
{
    public class MvcApplication : System.Web.HttpApplication
    {

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            
            WebApiConfig.Register(GlobalConfiguration.Configuration);
            GlobalFilters.Filters.Add(new LoggingFilterAttribute());
            GlobalFilters.Filters.Add(new HandleErrorAttribute());
            GlobalFilters.Filters.Add(new HandleErrorWithJson());

            SecurityHelper.SetupRoles();

            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            FluentValidationModelValidatorProvider.Configure();
        }
    }
}
