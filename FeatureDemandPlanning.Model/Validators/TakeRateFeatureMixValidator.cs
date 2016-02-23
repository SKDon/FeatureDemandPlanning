using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateFeatureMixValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateFeatureMixValidator(IDataContext context)
        {
            RuleFor(d => d.FeatureMixItems).SetCollectionValidator(new TakeRateFeatureMixOutOfRangeValidator(context));
        }

        public static async Task<FluentValidation.Results.ValidationResult> ValidateData(IDataContext context,
                                                         RawTakeRateData data)
        {
            var validator = new TakeRateFeatureMixValidator(context);

            return await Task.FromResult(validator.Validate(data));
        }
    }
}
