using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class FdpMarket : Market
    {
        public int? FdpMarketId { get; set; }
        public int? ProgrammeId { get; set; }
        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpMarketId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                GroupName,
                Name
            };
        }
    }
}
