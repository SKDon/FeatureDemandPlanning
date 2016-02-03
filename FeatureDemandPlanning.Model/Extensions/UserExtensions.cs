using System.Collections.Generic;
using System.Text;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class UserExtensions
    {
        public static string ToCommaSeperatedString(this IEnumerable<UserProgrammeMapping> programmes)
        {
            var sb = new StringBuilder();
            foreach (var mapping in programmes)
            {
                sb.Append(string.Format("{0} {1} ({2}), ", mapping.VehicleName, mapping.ModelYear, mapping.Action == UserAction.Edit ? "EDIT" : "VIEW"));
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 2) : "-";
        }

        public static string ToCommaSeperatedString(this IEnumerable<UserMarketMapping> markets)
        {
            var sb = new StringBuilder();
            foreach (var mapping in markets)
            {
                sb.Append(string.Format("{0} ({1}), ", mapping.Market, mapping.Action == UserAction.Edit ? "EDIT" : "VIEW"));
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 2) : "-";
        }
    }
}
