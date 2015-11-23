using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class SpecialFeatureMappingFilter : FeatureMappingFilter
    {
        public int? SpecialFeatureMappingId { get; set; }
        public new SpecialFeatureMappingAction Action { get; set; }

        public SpecialFeatureMappingFilter()
        {
            Action = SpecialFeatureMappingAction.NotSet;
        }

        public static SpecialFeatureMappingFilter FromSpecialFeatureMappingId(int? specialFeatureMappingId)
        {
            return new SpecialFeatureMappingFilter()
            {
                SpecialFeatureMappingId = specialFeatureMappingId
            };
        }
        public static SpecialFeatureMappingFilter FromFeatureMappingParameters(SpecialFeatureMappingParameters parameters)
        {
            return new SpecialFeatureMappingFilter()
            {
                SpecialFeatureMappingId = parameters.SpecialFeatureMappingId,
                Action = parameters.Action
            };
        }
    }
}
