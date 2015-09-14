
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ModelTrim : BusinessObject
    {
        public string TypeName { get { return "ModelTrim"; } }
        public int ProgrammeId { get; set; }
        public string Name { get; set; }
        public string Abbreviation { get; set; }
        public string Level { get; set; }
        public string DPCK { get; set; }
           
        // A blank constructor
        public ModelTrim() {;}
    }

    public static class ModelTrimExtensions
    {
        public static string ToCommaSeperatedList(this IEnumerable<ModelTrim> trimList)
        {
            var sb = new StringBuilder();
            foreach (var trim in trimList)
            {
                sb.Append(trim);
                sb.Append(", ");
            }
            var result = sb.ToString();
            return result.Take(result.Length - 2).ToString();
        }
    }
}