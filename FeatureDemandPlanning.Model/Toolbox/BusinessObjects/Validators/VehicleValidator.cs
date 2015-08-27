using FluentValidation;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public abstract class VehicleValidator : AbstractValidator<Vehicle>
    {
        public const string forecastVehicleEmpty = "Please specify a forecast vehicle";
        public const string programmeNotSet = "Please specify a programme";
        public const string modelYearNotSet = "Please specify a model year";

        public VehicleValidator()
        {
            CascadeMode = CascadeMode.StopOnFirstFailure;

            RuleFor(v => v).Must(NotBeAnEmptyVehicle).WithName("ForecastVehicle").WithMessage(forecastVehicleEmpty);
            RuleFor(v => v.ProgrammeId).NotEmpty().WithMessage(programmeNotSet);
            RuleFor(v => v.ModelYear).NotEmpty().WithMessage(modelYearNotSet);
        }

        public static bool NotBeAnEmptyVehicle(Vehicle vehicle)
        {
            return vehicle != null && (!(vehicle is EmptyVehicle) || vehicle.VehicleId.HasValue);
        }
    }
}
