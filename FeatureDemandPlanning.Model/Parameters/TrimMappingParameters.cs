using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TrimMappingParameters : TrimParameters
    {
        public int? DocumentId { get; set; }
        public int? TargetDocumentId { get; set; }
        public int? TrimMappingId { get; set; }
        public string ImportTrim { get; set; }
        public string Dpck { get; set; }
      
        public new TrimMappingAction Action { get; set; }

        public TrimMappingParameters()
        {
            Action = TrimMappingAction.NotSet;
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == TrimMappingAction.Delete || 
                Action == TrimMappingAction.Copy || 
                Action == TrimMappingAction.CopyAll)
            {
                return new
                {
                    TrimMappingId
                };
            }

            return new { };
        }
    }
}
