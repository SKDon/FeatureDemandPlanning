using FluentSecurity;
using FluentSecurity.Policy;

namespace FeatureDemandPlanning.Security
{
    public class DefaultSecurityPolicy : ISecurityPolicy
    {
        public PolicyResult Enforce(ISecurityContext context)
        {
            return PolicyResult.CreateFailureResult(this, "No security policy configured");
        }
    }
}