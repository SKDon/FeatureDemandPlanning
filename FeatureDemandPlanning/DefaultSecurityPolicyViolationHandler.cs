using System.Reflection;
using System.Web.Mvc;
using FluentSecurity;
using log4net;

namespace FeatureDemandPlanning
{
    public class DefaultSecurityPolicyViolationHandler : IPolicyViolationHandler
    {
        public ActionResult Handle(PolicyViolationException exception)
        {
            Log.Warn(exception);
            // A friendly page saying that this page hasn't been configured correctly
            return new RedirectResult("~/Error/NoSecurity.aspx");
        }

        protected static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}