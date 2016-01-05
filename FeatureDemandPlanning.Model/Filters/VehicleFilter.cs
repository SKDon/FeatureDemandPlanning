using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.Filters
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

        public static IVehicle ToVehicle(VehicleFilter filter)
        {
            return new Vehicle()
            {
                ProgrammeId = filter.ProgrammeId,
                VehicleId = filter.VehicleId,
                Code = filter.Code,
                Make = filter.Make,
                ModelYear = filter.ModelYear,
                Gateway = filter.Gateway
            };
        }
    }
}
