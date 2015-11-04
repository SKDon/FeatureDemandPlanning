using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class ModelYear
    {
        public string Name { get; set; }
        public string VehicleName { get; set; }
    }

    public class ModelYearComparer : IEqualityComparer<ModelYear>
    {
        public bool Equals(ModelYear x, ModelYear y)
        {
            return x.VehicleName.Equals(y.VehicleName, StringComparison.InvariantCultureIgnoreCase) && 
                x.Name.Equals(y.Name, StringComparison.InvariantCultureIgnoreCase);
        }

        public int GetHashCode(ModelYear obj)
        {
            return string.Format("{0}{1}", obj.VehicleName, obj.Name).GetHashCode(); 
        }
    }
}
