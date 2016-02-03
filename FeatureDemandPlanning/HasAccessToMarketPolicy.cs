using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentSecurity;
using FluentSecurity.Policy;

namespace FeatureDemandPlanning
{
    public class HasAccessToMarketPolicy : ISecurityPolicy
    {
        public FluentSecurity.PolicyResult Enforce(FluentSecurity.ISecurityContext context)
        {
            var marketId = 0;
            if (HttpContext.Current.Request.QueryString.AllKeys.Contains("MarketId") ||
                HttpContext.Current.Request.Form.AllKeys.Contains("MarketId") && 
                int.TryParse(HttpContext.Current.Request["MarketId"], out marketId))
            {
                return marketId == 17
                    ? PolicyResult.CreateFailureResult(this, "Cannot access market")
                    : PolicyResult.CreateSuccessResult(this);
            }
            return PolicyResult.CreateSuccessResult(this);
        }
    }
}