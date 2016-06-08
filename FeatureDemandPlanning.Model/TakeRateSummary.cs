using System;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateSummary
    {
        public int TakeRateId { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public int OxoDocId { get; set; }
        public string OxoDocument { get; set; }

        public int FdpTakeRateStatusId { get; set; }
        public string Status { get; set; }
        public string StatusDescription { get; set; }

        public string Version { get; set; }
        public bool IsCompleted { get; set; }

        public MarketReview MarketReview { get; set; }

        public string[] ToJQueryDataTableResult()
        {
            var url = new UrlHelper(HttpContext.Current.Request.RequestContext);

            return new[] 
            { 
                TakeRateId.ToString(),
                CreatedOn.ToString("dd/MM/yyyy"),
                CreatedBy,
                OxoDocument,
                Version,
                Status,
                UpdatedOn.HasValue ? UpdatedOn.Value.ToString("dd/MM/yyyy HH:mm") : "-",
                !string.IsNullOrEmpty(UpdatedBy) ? UpdatedBy : "-",
                //OxoDocId.ToString(),
                IsCompleted.ToString(),
                url.RouteUrl("TakeRateData", new { takeRateId = TakeRateId })
            };
        }
        public Publish Publish { get; set; }
    }
}
