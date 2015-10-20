using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class TrimMapping
    {
        public int FdpTrimMappingId { get; set; }
        public string ImportTrim { get; set; }
        public int ProgrammeId { get; set; }
        public int TrimId { get; set; }
    }
}
