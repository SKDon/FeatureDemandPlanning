using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    public class VehicleFilter : ProgrammeFilter
    {
        public int? VehicleIndex { get; set; }

        public static VehicleFilter FromVehicle(IVehicle vehicle)
        {
            return new VehicleFilter()
            {
                ProgrammeId = vehicle.ProgrammeId,
                VehicleId = vehicle.VehicleId,
                Code = vehicle.Code,
                Make = vehicle.Make,
                ModelYear = vehicle.ModelYear,
                Gateway = vehicle.Gateway
            };
        }
    }
}
