using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class DerivativeMappingFilter : DerivativeFilter
    {
        public int? DerivativeMappingId { get; set; }
        public new DerivativeMappingAction Action { get; set; }

        public DerivativeMappingFilter()
        {
            Action = DerivativeMappingAction.NotSet;
        }

        public static DerivativeMappingFilter FromDerivativeMappingId(int? derivativeMappingId)
        {
            return new DerivativeMappingFilter()
            {
                DerivativeMappingId = derivativeMappingId
            };
        }
        public static DerivativeMappingFilter FromDerivativeMappingParameters(DerivativeMappingParameters parameters)
        {
            return new DerivativeMappingFilter()
            {
                DerivativeMappingId = parameters.DerivativeMappingId,
                Action = parameters.Action
            };
        }
    }
}
