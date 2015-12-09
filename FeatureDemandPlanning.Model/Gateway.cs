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
        public string ModelYear { get; set; }
    }

    public class GatewayComparer : IEqualityComparer<Gateway>
    {
        public bool Equals(Gateway x, Gateway y)
        {
            return x.VehicleName.Equals(y.VehicleName, StringComparison.InvariantCultureIgnoreCase) &&
                x.ModelYear.Equals(y.ModelYear, StringComparison.InvariantCultureIgnoreCase) &&
                x.Name.Equals(y.Name, StringComparison.InvariantCultureIgnoreCase);
        }

        public int GetHashCode(Gateway obj)
        {
            return string.Format("{0}{1}{2}", obj.VehicleName, obj.ModelYear, obj.Name.ToUpper()).GetHashCode();
        }
    }
}
