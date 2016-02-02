using System.Reflection;
using System.Web;
using System.Web.Mvc;
using FluentSecurity;
using log4net;

namespace FeatureDemandPlanning
{
    public class RequireAnyRolePolicyViolationHandler : IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            // We should really use 401 - Unauthorized, however with windows authentication, that keeps asking for credentials
            // We can't have this as the user is already authenticated
            return new RedirectResult("~/Error/403.aspx");
        }

        protected static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}