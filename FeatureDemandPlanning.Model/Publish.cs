using System;
using System.Web;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class Publish
    {
        public int? FdpPublishId { get; set; }
        public int FdpVolumeHeaderId { get; set; }
        public int DocumentId { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public DateTime? PublishOn { get; set; }
        public string PublishBy { get; set; }
        public Programme Programme { get; set; }
        public OXODoc Document { get; set; }
        public int MarketId { get; set; }
        public string MarketGroup { get; set; }
        public string MarketName { get; set; }
        public string Status { get; set; }
        public string Comment { get; set; }
        public bool IsPublished { get; set; }

        public string[] ToJQueryDataTableResult()
        {
            var url = new UrlHelper(HttpContext.Current.Request.RequestContext);
           
            return new[] 
            { 
                FdpPublishId.GetValueOrDefault().ToString(),
                MarketId.ToString(),
                PublishOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                PublishBy,
                Programme.GetDisplayString(),
                Document.Gateway,
                Document.VersionLabel,
                Document.Status,
                MarketName,
                Comment,
                url.RouteUrl("TakeRateDataByMarket", new { takeRateId = FdpVolumeHeaderId, marketId = MarketId })
            };
        }
    }
}
