using System.Web;
using System.Web.Mvc;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToProgrammePolicyViolationHandler : PolicyViolationHandlerBase, IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            return new RedirectResult("~/Error/NoProgrammeAccess.aspx?Message=" + HttpUtility.UrlEncode(exception.Message));
        }
    }
}