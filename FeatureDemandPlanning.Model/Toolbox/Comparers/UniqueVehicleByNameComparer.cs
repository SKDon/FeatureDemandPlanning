using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Comparers
{
    public class UniqueVehicleByNameComparer : IEqualityComparer<IVehicle>
    {
        public bool Equals(IVehicle x, IVehicle y)
        {
            return x.Code.Equals(y.Code, StringComparison.InvariantCultureIgnoreCase);
        }

        public int GetHashCode(IVehicle obj)
        {
            return obj.Code.GetHashCode();
        }
    }
}
