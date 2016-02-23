using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class NonApplicableFeature0PercentValidator : AbstractValidator<RawTakeRateDataItem>
    {
        private const string Message =
            "Take rate of {0:P} for feature '{1}' is invalid for model '{2}'. Take rates for non-applicable features should be 0 %.";

        public NonApplicableFeature0PercentValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Must(d => d == 0)
                .WithMessage(
                    Message,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.NonApplicableFeaturesShouldBe0Percent, d));
        }
    }
}
