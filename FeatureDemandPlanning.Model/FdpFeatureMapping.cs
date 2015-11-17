using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpFeatureMapping : FdpFeature
    {
        public int? FdpFeatureMappingId { get; set; }
        public string ImportFeatureCode { get; set; }
        public bool? IsMappedFeature { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpFeatureMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportFeatureCode,
                FeatureCode,
                BrandDescription
            };
        }
        public static FdpFeatureMapping FromParameters(FeatureMappingParameters parameters)
        {
            return new FdpFeatureMapping()
            {
                FdpFeatureMappingId = parameters.FeatureMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
