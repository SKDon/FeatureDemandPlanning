using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class DerivativeMappingParameters : DerivativeParameters
    {
        public int? DerivativeMappingId { get; set; }
        public string ImportDerivativeCode { get; set; }
      
        public new DerivativeMappingAction Action { get; set; }

        public IEnumerable<string> CopyToGateways { get; set; }

        public DerivativeMappingParameters()
        {
            Action = DerivativeMappingAction.NotSet;
            CopyToGateways = Enumerable.Empty<string>();
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == DerivativeMappingAction.Delete || 
                Action == DerivativeMappingAction.Copy || 
                Action == DerivativeMappingAction.CopyAll)
            {
                return new
                {
                    DerivativeMappingId = DerivativeMappingId
                };
            }

            return new { };
        }
    }
}
