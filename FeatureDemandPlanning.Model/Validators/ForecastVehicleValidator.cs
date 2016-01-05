using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;
using System.Linq;

namespace FeatureDemandPlanning.Model.Validators
{
    public class ForecastVehicleValidator : VehicleValidator
    {
        public const string noGateway = "No gateway specified for '{0}'";
        public const string noTrim = "No trim levels available for '{0}'";

        public ForecastVehicleValidator() : base()
        {
            RuleSet("ForecastVehicle", () => {
                RuleFor(v => v)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(HaveProgramme)
                    .WithMessage(noProgramme)
                    .Must(HaveModelYear)
                    .WithMessage(noModelYear, f => f.Description)
                    .Must(HaveGateway)
                    .WithMessage(noGateway, f => f.Description)
                    .Must(HaveTrim)
                    .WithMessage(noTrim, f => f.Description);
            });
        }

        private bool HaveGateway(IVehicle vehicleToValidate)
        {
            return !string.IsNullOrEmpty(vehicleToValidate.Gateway);
        }

        private bool HaveTrim(IVehicle vehicleToValidate)
        {
            return vehicleToValidate.Programmes.Any() &&
                vehicleToValidate.Programmes.First().AllTrims.Any();
        }
    }
}
