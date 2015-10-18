using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Enumerations
{
    public enum ImportStatus
    {
        Queued = 1,
        Processing = 2,
        Processed = 3,
        Error = 4,
        Success = 5
    }
}
