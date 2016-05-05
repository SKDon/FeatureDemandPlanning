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
            // If the feature is in an EFG (with more than 1 item), then the take rate is determined by the options in the group
            // Otherwise it should have 100% take
            RuleFor(d => d)
                .Must(d => BeInExclusiveFeatureGroup(d) || Have100PercentTake(d))
                .WithMessage(
                    Message,
                    d => d.PercentageTakeRate,
                    d => d.FeatureDescription,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.StandardFeaturesShouldBe100Percent, d));
        }

        public bool BeInExclusiveFeatureGroup(RawTakeRateDataItem dataItem)
        {
            return !string.IsNullOrEmpty(dataItem.ExclusiveFeatureGroup) && dataItem.FeaturesInExclusiveFeatureGroup > 1;
        }
        public bool Have100PercentTake(RawTakeRateDataItem dataItem)
        {
            return dataItem.PercentageTakeRate == 1;
        }
    }
}
