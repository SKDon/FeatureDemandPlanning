using System.Web;
using System.Web.Mvc;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToMarketPolicyViolationHandler : PolicyViolationHandlerBase, IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            return new RedirectResult(string.Format("~/Error/NoMarketAccess.aspx?Message={0}", HttpUtility.UrlEncode(exception.Message)));
        }
    }
}