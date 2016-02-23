using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateSummaryValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateSummaryValidator(IDataContext context)
        {
            RuleFor(d => d.SummaryItems)
                .SetCollectionValidator(new TakeRateSummaryOutOfRangeValidator(context));
            RuleFor(d => d)
                .SetValidator(new TakeRateForModels100PercentValidator(context));
            RuleFor(d => d)
                .SetValidator(new VolumeForModelsNotEqualToMarketValidator(context));
        }
        
        public static async Task<FluentValidation.Results.ValidationResult> ValidateData(IDataContext context, 
                                                         RawTakeRateData data)
        {
            var validator = new TakeRateSummaryValidator(context);
            
            return await Task.FromResult(validator.Validate(data));
        }
    }
}
