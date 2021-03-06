﻿using System.Collections.Generic;
using System.Text;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class ModelTrimExtensions
    {
        public static string GetDisplayString(this ModelTrim trim)
        {
            if (!string.IsNullOrEmpty(trim.DPCK)) {
                return string.Format("{0} - {1} ({2})", trim.Name, trim.Level, trim.DPCK);
            }
            return string.Format("{0} - {1}", trim.Name, trim.Level);
        }
        
        public static string ToCommaSeperatedList(this IEnumerable<ModelTrim> trimList)
        {
            var sb = new StringBuilder();
            foreach (var trim in trimList)
            {
                sb.Append(trim.Name);
                sb.Append(", ");
            }
            var result = sb.ToString();
            if (result.Length > 0)
            {
                result = result.Substring(0, result.Length - 2);
            }
            return result;
        }
    }
}
