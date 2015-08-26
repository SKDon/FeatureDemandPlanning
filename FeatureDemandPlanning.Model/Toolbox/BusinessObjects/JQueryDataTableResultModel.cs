using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class JQueryDataTableResultModel
    {
        public string sEcho { get; set; }
        public int iTotalRecords { get; set; }
        public int iTotalDisplayRecords { get; set; }
        public List<string[]> aaData { get; private set; }

        public JQueryDataTableResultModel()
        {
            aaData = new List<string[]>();
        }

        public JQueryDataTableResultModel(string sEcho) : this()
        {
            this.sEcho = sEcho;
        }

        public JQueryDataTableResultModel(string sEcho, int totalRecords) : this(sEcho)
        {
            iTotalRecords = totalRecords;
            iTotalDisplayRecords = totalRecords;
        }

        /// <summary>
        /// Gets the results based on the parameters, the sEcho flag ensures the request matches the response
        /// to prevent XSS attacks
        /// </summary>
        /// <param name="para">The para.</param>
        /// <returns></returns>
        public static JQueryDataTableResultModel GetResultsFromParameters(JQueryDataTableParamModel para, int totalRecords)
        {
            return new JQueryDataTableResultModel(para.sEcho, totalRecords);
        }
    }
}