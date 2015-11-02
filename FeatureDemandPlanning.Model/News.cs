using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Model
{
    public class News
    {
        public int? FdpNewsId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public string Headline { get; set; }
        public string Body { get; set; }
    }
}
