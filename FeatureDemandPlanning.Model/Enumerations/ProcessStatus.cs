using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ProcessStatus
    {
        NotSet = 0,
        Success,
        Warning,
        Failure,
        Information
    }
}
