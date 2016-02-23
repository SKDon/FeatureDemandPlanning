using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class StandardFeature100PercentValidator : AbstractValidator<RawTakeRateDataItem>
    {
        private const string Message =
            "Take rate of {0:P} for feature '{1}' is invalid for model '{2}'. Take rates for standard features should not be less than 100 %.";

        public StandardFeature100PercentValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Must(d => d == 1)
                .WithMessage(
                    Message,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.StandardFeaturesShouldBe100Percent, d));
        }
    }
}
