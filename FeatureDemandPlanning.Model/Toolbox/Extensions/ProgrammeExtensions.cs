using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public static class ProgrammeExtensions
    {
        public static string GetDisplayString(this Programme programme)
        {
            return string.Format("{0} - {1} ({2})", programme.VehicleName, programme.VehicleAKA, programme.ModelYear);
        }
    }
}
