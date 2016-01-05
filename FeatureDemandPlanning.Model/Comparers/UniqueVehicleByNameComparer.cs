using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Comparers
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
