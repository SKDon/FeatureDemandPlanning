using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TrimMappingParameters : TrimParameters
    {
        public int? TrimMappingId { get; set; }
        public string ImportTrim { get; set; }
      
        public new TrimMappingAction Action { get; set; }

        public IEnumerable<string> CopyToGateways { get; set; }

        public TrimMappingParameters()
        {
            Action = TrimMappingAction.NotSet;
            CopyToGateways = Enumerable.Empty<string>();
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == TrimMappingAction.Delete || 
                Action == TrimMappingAction.Copy || 
                Action == TrimMappingAction.CopyAll)
            {
                return new
                {
                    TrimMappingId,
                    CopyToGateways
                };
            }

            return new { };
        }
    }
}
