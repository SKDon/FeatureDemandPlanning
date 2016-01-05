using System;

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
