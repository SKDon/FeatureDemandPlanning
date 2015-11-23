using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class FeatureMappingParameters : FeatureParameters
    {
        public int? FeatureMappingId { get; set; }
        public string ImportFeatureCode { get; set; }
      
        public new FeatureMappingAction Action { get; set; }

        public IEnumerable<string> CopyToGateways { get; set; }

        public FeatureMappingParameters()
        {
            Action = FeatureMappingAction.NotSet;
            CopyToGateways = Enumerable.Empty<string>();
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == FeatureMappingAction.Delete)
            {
                return new
                {
                    FeatureMappingId
                };
            }
            if (Action == FeatureMappingAction.Copy || Action == FeatureMappingAction.CopyAll)
            {
                return new
                {
                    FeatureMappingId,
                    CopyToGateways
                };
            }
            return new { };
        }
    }
}
