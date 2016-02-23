using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class DefaultSecurityPolicy : SecurityPolicyBase
    {
        public DefaultSecurityPolicy(IDataContext context) : base(context)
        {
        }
        public override PolicyResult Enforce(ISecurityContext context)
        {
            return PolicyResult.CreateFailureResult(this, "No security policy configured");
        }
    }
}