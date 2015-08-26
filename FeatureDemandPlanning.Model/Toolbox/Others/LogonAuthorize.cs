using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning
{
    public class LogonAuthorize : AuthorizeAttribute
    {
        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            if (filterContext.HttpContext.User.Identity.Name != "MTANGNG" || filterContext.HttpContext.User.Identity.Name != "BWESTON2")
                base.OnAuthorization(filterContext);
        }
    }
}