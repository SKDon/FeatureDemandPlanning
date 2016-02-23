using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateDataValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateDataValidator(IDataContext context)
        {
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new TakeRateDataOutOfRangeValidator(context));
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new StandardFeature100PercentValidator(context))
                .Where(d => d.IsStandardFeatureInGroup);
            RuleFor(d => d.DataItems)
                .SetCollectionValidator(new NonApplicableFeature0PercentValidator(context))
                .Where(d => d.IsNonApplicableFeatureInGroup);
            RuleFor(d => d)
                .SetValidator(new VolumeForFeatureGreaterThanModelValidator(context));
            RuleFor(d => d)
                .SetValidator(new TakeRateForEfgValidator(context));
            RuleFor(d => d)
                .SetValidator(new TakeRateForFeaturePackValidator(context));
        }
        
        public static async Task<FluentValidation.Results.ValidationResult> ValidateData(IDataContext context, 
                                                         RawTakeRateData data)
        {
            var validator = new TakeRateDataValidator(context);

            var results = await Task.FromResult(validator.Validate(data));

            // We need to process the state objects for validation errors of a certain type to ensure the payload
            // if sufficiently small.

            return results;
        }
    }
}
