using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    /// <summary>
    /// Class encapsulating filters for reducing list of available programmes
    /// </summary>
    public class ProgrammeFilter : FilterBase
    {
        public int? ProgrammeId { get; set; }
        public int? VehicleId { get; set; }
        public int? OxoDocId { get; set; }

        public string Make { get; set; }
        public string Code { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }

        public ProgrammeFilter()
        {

        }

        public ProgrammeFilter(int programmeId)
        {
            ProgrammeId = programmeId;
        }

        public override int GetHashCode()
        {
            unchecked
            {
                int hash = 17;

                hash = hash * 23 + (string.IsNullOrEmpty(Make) ? string.Empty : Make).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(Code) ? string.Empty : Code).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(ModelYear) ? string.Empty : ModelYear).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(Gateway) ? string.Empty : Gateway).GetHashCode();
              
                return hash;
            }
        }
    }
}
