using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class FeaturePackEquivalentTakeRateValidator : AbstractValidator<FeaturePack>
    {
        private const string Message = "Feature pack '{0}' for model '{1}' is invalid. Take rates for all features in the pack must be equivalent.";

        public FeaturePackEquivalentTakeRateValidator()
        {
            RuleFor(p => p)
                .Must(HaveEquivalentTakeRate)
                .WithMessage(Message,
                    p => p.PackName,
                    p => p.Model)
                .WithState(p => new ValidationState(ValidationRule.TakeRateForPackFeaturesShouldBeEquivalent, p));
        }
        private static bool HaveEquivalentTakeRate(FeaturePack pack)
        {
            return !pack.HasMultipleTakeRates(); ;
        }
    }
    public class TakeRateForFeaturePackValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateForFeaturePackValidator()
        {
            RuleForEach(d => d.FeaturePacks)
                .SetValidator(new FeaturePackEquivalentTakeRateValidator());
        }
        
    }
}
