using System;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class MarketReview
    {
        public int? FdpMarketReviewId { get; set; }
        public int FdpVolumeHeaderId { get; set; }
        public int DocumentId { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public Programme Programme { get; set; }
        public OXODoc Document { get; set; }
        public int MarketId { get; set; }
        public string MarketGroup { get; set; }
        public string MarketName { get; set; }
        public int FdpMarketReviewStatusId { get; set; }
        public string Status { get; set; }
        public string Comment { get; set; }
        public MarketReviewStatus StatusCode {
            get { return (MarketReviewStatus) FdpMarketReviewStatusId; }
        }

        public string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpMarketReviewId.GetValueOrDefault().ToString(),
                MarketId.ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Document.Gateway,
                Document.VersionLabel,
                Document.Status,
                MarketName,
                Status,
                Comment
            };
        }
    }
}
