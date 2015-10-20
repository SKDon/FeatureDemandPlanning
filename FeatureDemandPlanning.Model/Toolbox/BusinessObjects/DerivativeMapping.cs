using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class DerivativeMapping
    {
        public int FdpDerivativeMappingId { get; set; }

        public string ImportDerivativeCode { get; set; }

        public int ProgrammeId { get; set; }
        public int BodyId { get; set; }
        public int EngineId { get; set; }
        public int TransmissionId { get; set; }
    }
}
