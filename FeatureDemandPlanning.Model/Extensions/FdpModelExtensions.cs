using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class FdpModelExtensions
    {
        public static string ToCommaSeperatedString(this IEnumerable<FdpModel> models)
        {
            var retVal = string.Empty;
            var sb = new StringBuilder();
            foreach (var model in models)
            {
                if (model.FdpModelId.HasValue)
                {
                    sb.Append(string.Format("[F{0}],", model.FdpModelId));
                }
                else
                {
                    sb.Append(string.Format("[O{0}],", model.Id));
                }
            }

            if (sb.Length > 0)
                retVal = sb.ToString().Substring(0, sb.Length - 1);

            return retVal;
        }
    }
}
