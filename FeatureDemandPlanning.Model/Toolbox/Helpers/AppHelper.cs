using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Configuration;
using FeatureDemandPlanning.BusinessObjects;
using System.Diagnostics;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Helpers
{
    public static class AppHelper
    {
        public static void LogError(string methodName, string message, string userCDSID)
        {
            try
            {
                string cs = "OXOApp";
                EventLog elog = new EventLog();
                if (!EventLog.SourceExists(cs))
                {
                    EventLog.CreateEventSource(cs, cs);
                }
                elog.Source = cs;
                elog.EnableRaisingEvents = true;
                elog.WriteEntry(methodName + ':' + message);
            }
            catch (Exception ex) { ;}

        }

        public static string GetWindowsID(System.Security.Principal.IPrincipal user)
        {
            string retVal;

            if (user.Identity.Name.Contains('\\'))
                retVal = user.Identity.Name.Split('\\')[1];
            else
                retVal = user.Identity.Name;

            return retVal.ToLower();

        }

        public static DateTime UnixTimeStampToDateTime(Int64 unixTimeStamp)
        {
            // Unix timestamp is seconds past epoch
            DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            dtDateTime = dtDateTime.AddSeconds(unixTimeStamp).ToUniversalTime();
            DateTime gmtDateTime = DateTime.SpecifyKind(dtDateTime, DateTimeKind.Utc).ToLocalTime();

            return gmtDateTime;
        }

        public static Int64 DateTimeToUnixTimeStamp(DateTime date)
        {
            Int64 retVal;
            DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            date = date.ToUniversalTime();
            retVal = (Int64)date.Subtract(dtDateTime).TotalSeconds;
            return retVal;
        }

        public static string ToJson(object obj)
        {
            string retVal = "";

            try
            {
                retVal = new JavaScriptSerializer().Serialize(obj);
            }
            catch (Exception ex)
            {
                ;
            }
            return retVal;
        }

        //public static List<ModelFilter> GetModelFiltersFromJson(string json)
        //{
        //    string temp = Uri.UnescapeDataString(json);
        //    JavaScriptSerializer json_serializer = new JavaScriptSerializer();
        //    List<ModelFilter> result = (List<ModelFilter>)json_serializer.Deserialize(temp, typeof(List<ModelFilter>));
        //    return result;
        //}

    }

    public class PerformanceActionFilter : IActionFilter
    {
        private Stopwatch stopWatch = new Stopwatch();

        public void OnActionExecuting(ActionExecutingContext filterContext)
        {
            stopWatch.Reset();
            stopWatch.Start();
        }

        public void OnActionExecuted(ActionExecutedContext filterContext)
        {
            stopWatch.Stop();
            var executionTime = stopWatch.ElapsedMilliseconds;
            
        }        
    }

    public class PerformanceResultFilter : IResultFilter
    {
        private Stopwatch stopWatch = new Stopwatch();

       

        public void OnResultExecuting(ResultExecutingContext filterContext)
        {
            stopWatch.Reset();
            stopWatch.Start();
        }

        public void OnResultExecuted(ResultExecutedContext filterContext)
        {
            stopWatch.Stop();
            var executionTime = stopWatch.ElapsedMilliseconds;
        }
    }
}