using System.Web.Mvc;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class RequireAnyRolePolicyViolationHandler : PolicyViolationHandlerBase, IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            // We should really use 401 - Unauthorized, however with windows authentication, that keeps asking for credentials
            // We can't have this as the user is already authenticated
            return new RedirectResult("~/Error/403.aspx");
        }
    }
}