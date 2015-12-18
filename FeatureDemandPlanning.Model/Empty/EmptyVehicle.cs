using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Empty
{
    public class EmptyVehicle : Vehicle
    {
        public EmptyVehicle()
        {
            Make = string.Empty;
            Code = string.Empty;
            ModelYear = string.Empty;
            DerivativeCode = string.Empty;
            Gateway = string.Empty;
            ImageUri = string.Empty;
            //Description = string.Empty;
        }
    }
}
