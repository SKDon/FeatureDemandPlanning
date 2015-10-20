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
        public int iTotalRecords { get; set; }
        public int iTotalDisplayRecords { get; set; }
        public int TotalSuccess { get; set; }
        public int TotalFail { get; set; }
        public List<string[]> aaData { get; private set; }

        public JQueryDataTableResultModel()
        {
            aaData = new List<string[]>();
        }

        
        public JQueryDataTableResultModel(int totalRecords) : this()
        {
            iTotalRecords = totalRecords;
            iTotalDisplayRecords = totalRecords;
        }

        public JQueryDataTableResultModel(int totalRecords, int totalDisplayRecords) : this(totalRecords)
        {
            iTotalDisplayRecords = totalDisplayRecords;
        }

        //public static JQueryDataTableResultModel GetResultsFromParameters(JQueryDataTableParameters para, 
        //    int totalRecords, 
        //    int totalDisplayRecords)
        //{
        //    return new JQueryDataTableResultModel(totalRecords, totalDisplayRecords);
        //}
    }
}