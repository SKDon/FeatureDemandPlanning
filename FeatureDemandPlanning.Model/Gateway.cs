using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class Gateway
    {
        public int? ProgrammeId { get; set; }
        public string Name { get; set; }
        public int DisplayOrder { get; set; }
        public string VehicleName { get; set; }
    }

    public class GatewayComparer : IEqualityComparer<Gateway>
    {
        public bool Equals(Gateway x, Gateway y)
        {
            return x.VehicleName.Equals(y.VehicleName, StringComparison.InvariantCultureIgnoreCase) &&
                x.Name.Equals(y.Name, StringComparison.InvariantCultureIgnoreCase);
        }

        public int GetHashCode(Gateway obj)
        {
            return string.Format("{0}{1}", obj.VehicleName, obj.Name.ToUpper()).GetHashCode();
        }
    }
}
