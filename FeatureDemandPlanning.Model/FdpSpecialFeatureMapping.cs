using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpSpecialFeatureMapping : FdpFeatureMapping
    {
        public int? FdpSpecialFeatureMappingId { get; set; }
        public string SpecialFeatureType { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpSpecialFeatureMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportFeatureCode,
                Description
            };
        }
        public static FdpSpecialFeatureMapping FromParameters(SpecialFeatureMappingParameters parameters)
        {
            return new FdpSpecialFeatureMapping()
            {
                FdpSpecialFeatureMappingId = parameters.SpecialFeatureMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
