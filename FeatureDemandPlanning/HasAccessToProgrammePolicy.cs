using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentSecurity.Policy;

namespace FeatureDemandPlanning
{
    public class HasAccessToProgrammePolicy : ISecurityPolicy
    {
        public FluentSecurity.PolicyResult Enforce(FluentSecurity.ISecurityContext context)
        {
            throw new NotImplementedException();
        }
    }
}