using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpTrimMapping : FdpTrim
    {
        public int? FdpTrimMappingId { get; set; }
        public string ImportTrim { get; set; }
        public bool? IsMappedTrim { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpTrimMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportTrim,
                Name,
                Level
            };
        }
        public static FdpTrimMapping FromParameters(TrimMappingParameters parameters)
        {
            return new FdpTrimMapping()
            {
                FdpTrimMappingId = parameters.TrimMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
