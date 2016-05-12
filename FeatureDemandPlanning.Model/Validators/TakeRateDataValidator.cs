using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateDataValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateDataValidator()
        {
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new TakeRateDataOutOfRangeValidator());
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new NonApplicableFeature0PercentValidator())
                .Where(d => d.IsNonApplicableFeatureInGroup);
            RuleFor(d => d)
                .SetValidator(new TakeRateForEfgValidator());
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new StandardFeature100PercentValidator())
                .Where(d => d.IsStandardFeatureInGroup);
            RuleFor(d => d)
                .SetValidator(new VolumeForFeatureGreaterThanModelValidator());
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new NonCodedFeatureTakeRateValidator());
            RuleFor(d => d)
                .SetValidator(new TakeRateForFeaturePackValidator());
        }
        
        public static FluentValidation.Results.ValidationResult ValidateData(RawTakeRateData data)
        {
            return new TakeRateDataValidator().Validate(data);
        }
    }
}
