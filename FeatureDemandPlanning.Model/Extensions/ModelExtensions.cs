using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class ModelExtensions
    {
        public static string ToCommaSeperatedString(this IEnumerable<Model> models)
        {
            var retVal = string.Empty;
            var sb = new StringBuilder();
            foreach (var model in models) {
                sb.Append(string.Format("[{0}],", model.Id));
            }

            if (sb.Length > 0)
                retVal = sb.ToString().Substring(0, sb.Length - 1);

            return retVal;
        }

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
