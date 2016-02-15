using System;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;
using FluentSecurity.Policy;

namespace FeatureDemandPlanning.Security
{
    public abstract class SecurityPolicyBase : ISecurityPolicy
    {
        protected SecurityPolicyBase(IDataContext context)
        {
            Context = context;
        }
        public virtual PolicyResult Enforce(ISecurityContext context)
        {
            throw new NotImplementedException();
        }
        protected string GetActionParameter(string parameterName, ISecurityContext fromContext)
        {
            var retVal = string.Empty;
            NameValueCollection httpParameters = null;
            HttpVerbs httpVerb;
            Enum.TryParse(HttpContext.Current.Request.HttpMethod, true, out httpVerb);

            switch (httpVerb)
            {
                case HttpVerbs.Get:
                    httpParameters = HttpContext.Current.Request.QueryString;
                    break;
                case HttpVerbs.Post:
                    httpParameters = HttpContext.Current.Request.Form;
                    break;
                case HttpVerbs.Put:
                    break;
                case HttpVerbs.Delete:
                    break;
                case HttpVerbs.Head:
                    break;
                case HttpVerbs.Patch:
                    break;
                case HttpVerbs.Options:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            if (httpParameters != null && httpParameters.AllKeys.Contains(parameterName, StringComparer.OrdinalIgnoreCase))
            {
                retVal = httpParameters[parameterName];
            }

            return retVal;
        }
        protected readonly IDataContext Context;
    }
}
