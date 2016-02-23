using System;
using System.Reflection;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using FeatureDemandPlanning.Bindings;
using FeatureDemandPlanning.Bindings.Modules;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Security;
using FluentValidation.Mvc;
using log4net;
using Ninject;

namespace FeatureDemandPlanning
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            var kernel = new StandardKernel();
            kernel.Load(
                new DataContextModule(), 
                new SecurityModule(),
                new ControllerModule()
                );
            ControllerBuilder.Current.SetControllerFactory(new ControllerFactory(kernel));
            
            WebApiConfig.Register(GlobalConfiguration.Configuration);
            GlobalFilters.Filters.Add(new LoggingFilterAttribute());
            GlobalFilters.Filters.Add(new HandleErrorAttribute());
            GlobalFilters.Filters.Add(new HandleErrorWithJson());

            FluentSecurityHelper.SetupRoles();

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
