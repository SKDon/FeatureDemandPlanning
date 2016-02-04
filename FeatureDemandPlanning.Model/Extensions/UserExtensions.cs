using System;
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

        public static string ToCommaSeperatedString(this IEnumerable<UserRole> roles)
        {
            var sb = new StringBuilder();
            foreach (var role in roles)
            {
                sb.Append(Enum.GetName(role.GetType(), role));
                sb.Append(", ");
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 2) : "-";
        }

        public static string ToPermissionString(this IEnumerable<UserProgrammeMapping> programmes)
        {
            var sb = new StringBuilder();
            foreach (var programme in programmes)
            {
                sb.Append(string.Format("{0}{1}", programme.Action == UserAction.Edit ? "E" : "V", programme.ProgrammeId));
                sb.Append(",");
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 1) : string.Empty;
        }
        public static string ToPermissionString(this IEnumerable<UserMarketMapping> markets)
        {
            var sb = new StringBuilder();
            foreach (var market in markets)
            {
                sb.Append(string.Format("{0}{1}", market.Action == UserAction.Edit ? "E" : "V", market.MarketId));
                sb.Append(",");
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 1) : string.Empty;
        }
        public static string ToPermissionString(this IEnumerable<UserRole> roles)
        {
            var sb = new StringBuilder();
            foreach (var role in roles)
            {
                sb.Append((int) role);
                sb.Append(",");
            }
            return sb.Length > 0 ? sb.ToString().Substring(0, sb.Length - 1) :string.Empty;
        }
    }
}
