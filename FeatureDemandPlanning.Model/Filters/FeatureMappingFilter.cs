using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class FeatureMappingFilter : FeatureFilter
    {
        public int? FeatureMappingId { get; set; }
        public new FeatureMappingAction Action { get; set; }

        public FeatureMappingFilter()
        {
            Action = FeatureMappingAction.NotSet;
        }

        public static FeatureMappingFilter FromFeatureMappingId(int? derivativeMappingId)
        {
            return new FeatureMappingFilter()
            {
                FeatureMappingId = derivativeMappingId
            };
        }
        public static FeatureMappingFilter FromFeatureMappingParameters(FeatureMappingParameters parameters)
        {
            return new FeatureMappingFilter()
            {
                FeatureMappingId = parameters.FeatureMappingId,
                Action = parameters.Action
            };
        }
    }
}
