using System;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class DateTimeExtensions
    {
        public static DateTime UnixTimeStampToDateTime(this long unixTimeStamp)
        {
            // Unix timestamp is seconds past epoch
            var dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            dtDateTime = dtDateTime.AddSeconds(unixTimeStamp).ToUniversalTime();
            var gmtDateTime = DateTime.SpecifyKind(dtDateTime, DateTimeKind.Utc).ToLocalTime();

            return gmtDateTime;
        }
        public static long ToUnixTimeStamp(this DateTime date)
        {
            var dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            date = date.ToUniversalTime();
            var retVal = (long)date.Subtract(dtDateTime).TotalSeconds;
            return retVal;
        }
    }
}
