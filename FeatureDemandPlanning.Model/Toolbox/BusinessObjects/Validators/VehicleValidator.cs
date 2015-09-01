using FluentValidation;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public abstract class VehicleValidator : AbstractValidator<Vehicle>
    {
        public const string programmeNotSet = "Please specify a programme";
        public const string modelYearNotSet = "Please specify a model year";

        public VehicleValidator()
        {
            CascadeMode = CascadeMode.StopOnFirstFailure;

            RuleFor(v => v.ProgrammeId).NotEmpty().WithMessage(programmeNotSet);
            RuleFor(v => v.ModelYear).NotEmpty().WithMessage(modelYearNotSet);
        }

        public static bool NotBeAnEmptyVehicle(Vehicle vehicle)
        {
            return vehicle != null && (!(vehicle is EmptyVehicle) || vehicle.VehicleId.HasValue);
        }

        public static bool NotBeAnEmptyVehicle(VehicleWithIndex vehicle)
        {
            return vehicle != null && (!(vehicle.Vehicle is EmptyVehicle) || vehicle.Vehicle.VehicleId.HasValue);
        }
    }
}
