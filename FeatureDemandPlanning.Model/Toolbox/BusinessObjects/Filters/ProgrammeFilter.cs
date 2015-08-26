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

        public string Make { get; set; }
        public string Name { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
    }
}
