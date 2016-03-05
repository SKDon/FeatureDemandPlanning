using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class NonCodedFeatureTakeRateValidator : AbstractValidator<RawTakeRateDataItem>
    {
        private const string Message =
            "Take rate of {0:P} for feature '{1}' is invalid for model '{2}'. Take rates for non-coded features should be 0 %.";

        public NonCodedFeatureTakeRateValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Must(d => d == 0)
                .When(d => d.IsOrphanedData)
                .WithMessage(
                    Message,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.NonCodedFeatureHasTakeRate, d));
        }
    }
}
