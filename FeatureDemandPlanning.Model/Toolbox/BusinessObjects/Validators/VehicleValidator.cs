using FeatureDemandPlanning.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public abstract class VehicleValidator : AbstractValidator<Vehicle>
    {
        public const string noProgramme = "No programme specified";
        public const string noModelYear = "No model year specified for '{0}'";

        public VehicleValidator()
        {
        }

        public static bool NotBeAnEmptyVehicle(IVehicle vehicle)
        {
            return vehicle != null && (!(vehicle is EmptyVehicle) || vehicle.VehicleId.HasValue);
        }

        public static bool NotBeAnEmptyVehicle(VehicleWithIndex vehicle)
        {
            return vehicle != null && (!(vehicle.Vehicle is EmptyVehicle) || vehicle.Vehicle.VehicleId.HasValue);
        }

        public static bool HaveProgramme(IVehicle vehicleToValidate)
        {
            return !string.IsNullOrEmpty(vehicleToValidate.Code);
        }

        public static bool HaveModelYear(IVehicle vehicleToValidate)
        {
            return !string.IsNullOrEmpty(vehicleToValidate.ModelYear);
        }
    }
}
