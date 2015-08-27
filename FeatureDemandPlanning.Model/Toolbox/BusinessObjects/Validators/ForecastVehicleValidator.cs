using FluentValidation;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public class ForecastVehicleValidator : VehicleValidator
    {
        public const string gatewayNotSet = "Please specify a gateway";

        public ForecastVehicleValidator() : base()
        {
            RuleFor(v => v.Gateway).NotEmpty().WithMessage(gatewayNotSet);
        }
    }
}
