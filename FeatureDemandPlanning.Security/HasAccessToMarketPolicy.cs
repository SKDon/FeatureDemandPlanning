using System.Linq;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToMarketPolicy : PolicyBase
    {
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
        private static bool HasAccessToMarket(int marketId)
        {
            IDataContext context = new DataContext(SecurityHelper.GetAuthenticatedUser());
            var user = context.User.GetUser();

            return user.Markets.Any(m => m.MarketId == marketId);
        }
        private static string GetMarketName(int marketId)
        {
            IDataContext context = new DataContext(SecurityHelper.GetAuthenticatedUser());
            var market = context.Market.GetMarket(marketId);

            return market != null ? market.Name : string.Empty;
        }
    }
}