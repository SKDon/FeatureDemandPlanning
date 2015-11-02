using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class EngineCodeMapping : Programme
    {
        public int? MappingId { get; set; }
        public int ProgrammeId { get; set; }
        public int EngineId { get; set; }
        public string EngineSize { get; set; }
        public string Cylinder { get; set; }
        public string Fuel { get; set; }
        public string Power { get; set; }
        public string Electrification { get; set; }

        public string ExternalEngineCode { get; set; }
    }
}
