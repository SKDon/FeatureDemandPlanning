using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

namespace FeatureDemandPlanning.Model
{
    public class JQueryDataTableSearch
    {
        public bool regex { get; set; }
        public string value { get; set; }

        public JQueryDataTableSearch()
        {
            regex = false;
            value = string.Empty;
        }
    }
    public class JQueryDataTableSort
    {
        public int column { get; set; }
        public string dir { get; set; }

        public JQueryDataTableSort()
        {
            column = 0;
            dir = "ASC";
        }
    }
    public class JQueryDataTableParameters
    {
        public int draw { get; set; }
        public int length { get; set; }
        public List<JQueryDataTableSort> order { get; set; }
        public JQueryDataTableSearch search { get; set; }
        public int start { get; set; }

        public JQueryDataTableParameters()
        {
            draw = 0;
            length = 0;
            order = Enumerable.Empty<JQueryDataTableSort>().ToList();
            search = new JQueryDataTableSearch();
            start = 0;
        }
    }
}