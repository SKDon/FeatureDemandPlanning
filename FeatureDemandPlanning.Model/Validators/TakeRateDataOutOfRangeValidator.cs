using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateDataOutOfRangeValidator : AbstractValidator<RawTakeRateDataItem>
    {
        private const string LowerLimitMessage =
            "Take rate of {0:P} for feature '{1}' is invalid for model '{2}'. Take rates should not be less than 0 %.";
        private const string UpperLimitMessage =
            "Take rate of {0:P} for feature '{1}' is invalid for model '{2}'. Take rates should not be more than 100 %.";

        public TakeRateDataOutOfRangeValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Cascade(CascadeMode.StopOnFirstFailure)
                .GreaterThanOrEqualTo(0)
                .WithMessage(
                    LowerLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.TakeRateOutOfRange, d))
                .LessThanOrEqualTo(1)
                .WithMessage(
                    UpperLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.TakeRateOutOfRange, d));
        }
    }
}
