using System.Linq;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToMarketPolicy : SecurityPolicyBase
    {
        public HasAccessToMarketPolicy(IDataContext context) : base(context)
        {
        }
        public override PolicyResult Enforce(ISecurityContext context)
        {
            var marketId = GetMarketParameter(context);
            if (!marketId.HasValue || HasAccessToMarket(marketId.Value))
            {
                return PolicyResult.CreateSuccessResult(this);
            }

            return PolicyResult.CreateFailureResult(this, string.Format("User '{0}' does not have sufficient permissions to access data for market '{1}'.", 
                SecurityHelper.GetAuthenticatedUser(), 
                GetMarketName(marketId.Value)));
        }
        private int? GetMarketParameter(ISecurityContext context)
        {
            int marketId;
            var marketParameter = GetActionParameter("MarketId", context);
            if (!string.IsNullOrEmpty(marketParameter) && int.TryParse(marketParameter, out marketId) && marketId != 0)
            {
                return marketId;
            }
            return null;
        }
        private bool HasAccessToMarket(int marketId)
        {
            var user = Context.User.GetUser();

            return user.Markets.Any(m => m.MarketId == marketId) || user.HasAccessAllMarketsRole();
        }
        private string GetMarketName(int marketId)
        {
            var market = Context.Market.GetMarket(marketId);

            return market != null ? market.Name : string.Empty;
        }
    }
}