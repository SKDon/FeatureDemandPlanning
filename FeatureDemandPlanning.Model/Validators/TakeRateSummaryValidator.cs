using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateSummaryValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateSummaryValidator()
        {
            RuleFor(d => d.SummaryItems)
                .SetCollectionValidator(new TakeRateSummaryOutOfRangeValidator());
            RuleFor(d => d)
                .SetValidator(new TakeRateForModels100PercentValidator());
            RuleFor(d => d)
                .SetValidator(new VolumeForModelsNotEqualToMarketValidator());
        }
        
        public static FluentValidation.Results.ValidationResult ValidateData(RawTakeRateData data)
        {
            var validator = new TakeRateSummaryValidator();
            
            return validator.Validate(data);
        }
    }
}
