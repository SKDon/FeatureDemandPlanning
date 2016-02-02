using FluentSecurity;
using FluentSecurity.Policy;

namespace FeatureDemandPlanning
{
    public class DefaultSecurityPolicy : ISecurityPolicy
    {
        public PolicyResult Enforce(FluentSecurity.ISecurityContext context)
        {
            return PolicyResult.CreateFailureResult(this, "No security policy configured");
        }
    }
}