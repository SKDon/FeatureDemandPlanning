using System;
using System.Reflection;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using FeatureDemandPlanning.Model.Attributes;
using FluentValidation.Mvc;
using log4net;

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

            Security.FluentSecurityHelper.SetupRoles();

            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            FluentValidationModelValidatorProvider.Configure();
        }

        protected void Application_Error(object sender, EventArgs eventArgs)
        {
            var error = Server.GetLastError();
            Log.Error(error);
        }

        protected static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}
