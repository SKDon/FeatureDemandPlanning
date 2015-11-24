using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpMarketMapping : FdpMarket
    {
        public int? FdpMarketMappingId { get; set; }
        public string ImportMarket { get; set; }
        public bool? IsMappedMarket { get; set; }
        public bool IsGlobalMapping { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpMarketMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportMarket,
                GroupName,
                Name
            };
        }
        public static FdpMarketMapping FromParameters(MarketMappingParameters parameters)
        {
            return new FdpMarketMapping()
            {
                FdpMarketMappingId = parameters.MarketMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
