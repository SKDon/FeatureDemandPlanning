using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ImportStatus
    {
        NotSet = 0,
        Queued = 1,
        Processing = 2,
        Processed = 3,
        Error = 4,
        Success = 5,
        Imported = 6
    }
}
