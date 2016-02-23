using System.Threading.Tasks;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateFeatureMixValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateFeatureMixValidator()
        {
            RuleFor(d => d.FeatureMixItems).SetCollectionValidator(new TakeRateFeatureMixOutOfRangeValidator());
        }

        public static FluentValidation.Results.ValidationResult ValidateData(RawTakeRateData data)
        {
            var validator = new TakeRateFeatureMixValidator();

            return validator.Validate(data);
        }
    }
}
