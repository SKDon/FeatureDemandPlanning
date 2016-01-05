using FeatureDemandPlanning.Model.Enumerations;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class SpecialFeatureMappingParameters : FeatureMappingParameters
    {
        public int? SpecialFeatureMappingId { get; set; }
        public new SpecialFeatureMappingAction Action { get; set; }

        public SpecialFeatureMappingParameters()
        {
            Action = SpecialFeatureMappingAction.NotSet;
            CopyToGateways = Enumerable.Empty<string>();
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == SpecialFeatureMappingAction.Delete)
            {
                return new
                {
                    SpecialFeatureMappingId
                };
            }
            if (Action == SpecialFeatureMappingAction.Copy || Action == SpecialFeatureMappingAction.CopyAll)
            {
                return new
                {
                    SpecialFeatureMappingId,
                    CopyToGateways
                };
            }

            return new { };
        }
    }
}
