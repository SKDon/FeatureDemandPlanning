using System;
using System.Collections.Generic;
using System.Text;

namespace FeatureDemandPlanning.Model.Extensions
{
    // Convert the string to camel case.
    public static class StringExtensions
    {
        public static string ToCamelCase(this string inputString)
        {
            // If there are 0 or 1 characters, just return the string.
            if (inputString == null || inputString.Length < 2)
                return inputString;

            // Split the string into words.
            string[] words = inputString.Split(
                new char[] { },
                StringSplitOptions.RemoveEmptyEntries);

            // Combine the words.
            string result = words[0].ToLower();
            for (int i = 1; i < words.Length; i++)
            {
                result +=
                    words[i].Substring(0, 1).ToUpper() +
                    words[i].Substring(1);
            }

            return result;
        }

        public static string ToCommaSeperatedList(this IEnumerable<string> stringList)
        {
            var sb = new StringBuilder();
            foreach (var s in stringList)
            {
                sb.Append(s);
                sb.Append(", ");
            }
            var result = sb.ToString();
            if (result.Length > 0)
            {
                result = result.Substring(0, result.Length - 2);
            }
            return result;
        }

        public static string Truncate(this string value, int length)
        {
            if (value == null)
                throw new ArgumentNullException("value");
            return value.Length <= length ? value : value.Substring(0, length);
        }
    }
}
