using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class TrimMappingFilter : TrimFilter
    {
        public int? TrimMappingId { get; set; }
        public new TrimMappingAction Action { get; set; }

        public TrimMappingFilter()
        {
            Action = TrimMappingAction.NotSet;
            IncludeAllTrim = false;
        }

        public static TrimMappingFilter FromTrimMappingId(int? trimMappingId)
        {
            return new TrimMappingFilter()
            {
                TrimMappingId = trimMappingId
            };
        }
        public static TrimMappingFilter FromTrimMappingParameters(TrimMappingParameters parameters)
        {
            return new TrimMappingFilter()
            {
                TrimMappingId = parameters.TrimMappingId,
                Action = parameters.Action
            };
        }
    }
}
