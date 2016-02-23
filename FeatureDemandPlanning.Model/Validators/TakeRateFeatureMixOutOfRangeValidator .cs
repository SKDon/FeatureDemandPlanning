using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateFeatureMixOutOfRangeValidator : AbstractValidator<RawTakeRateFeatureMixItem>
    {
        private const string LowerLimitMessage =
            "Take rate of {0:P} for feature '{1}' is invalid. Take rates should not be less than 0 %.";
        private const string UpperLimitMessage =
            "Take rate of {0:P} for feature '{1}' is invalid. Take rates should not be more than 100 %.";

        public TakeRateFeatureMixOutOfRangeValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Cascade(CascadeMode.StopOnFirstFailure)
                .GreaterThanOrEqualTo(0)
                .WithMessage(
                    LowerLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription)
                .LessThanOrEqualTo(1)
                .WithMessage(
                    UpperLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription)
                .WithState(d => new ValidationState(ValidationRule.TakeRateOutOfRange, d));

        }
    }
}
