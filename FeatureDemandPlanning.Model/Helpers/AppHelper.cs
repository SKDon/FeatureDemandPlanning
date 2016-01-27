using System;
using System.Linq;
using System.Web.Script.Serialization;
using System.Diagnostics;
using System.Reflection;
using System.Web.Mvc;
using log4net;

namespace FeatureDemandPlanning.Model.Helpers
{
    public static class AppHelper
    {
        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
        
        public static void LogError(string methodName, string message, string userCDSID)
        {
            Log.Error(string.Format("{0} - {1} - {2}", userCDSID, methodName, message));
        }

        public static void LogError(Exception ex)
        {
            Log.Error(ex);
        }

        public static string GetWindowsId(System.Security.Principal.IPrincipal user)
        {
            var retVal = user.Identity.Name.Contains('\\') ? user.Identity.Name.Split('\\')[1] : user.Identity.Name;

            return retVal.ToLower();
        }

        public static DateTime UnixTimeStampToDateTime(long unixTimeStamp)
        {
            // Unix timestamp is seconds past epoch
            var dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            dtDateTime = dtDateTime.AddSeconds(unixTimeStamp).ToUniversalTime();
            var gmtDateTime = DateTime.SpecifyKind(dtDateTime, DateTimeKind.Utc).ToLocalTime();

            return gmtDateTime;
        }

        public static long DateTimeToUnixTimeStamp(DateTime date)
        {
            var dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            date = date.ToUniversalTime();
            var retVal = (long)date.Subtract(dtDateTime).TotalSeconds;
            return retVal;
        }

        public static string ToJson(object obj)
        {
            var retVal = "";

            try
            {
                retVal = new JavaScriptSerializer().Serialize(obj);
            }
            catch
            {
                // ignored
            }
            return retVal;
        }
    }
}