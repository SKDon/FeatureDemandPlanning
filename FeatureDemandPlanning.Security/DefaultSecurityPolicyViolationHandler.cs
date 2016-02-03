using System.Web.Mvc;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class DefaultSecurityPolicyViolationHandler : PolicyViolationHandlerBase, IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            // A friendly page saying that this page hasn't been configured correctly
            return new RedirectResult("~/Error/NoSecurity.aspx");
        }
    }
}