using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class FeaturePackEquivalentTakeRateValidator : AbstractValidator<FeaturePack>
    {
        private const string Message = "Feature pack '{0}' for model '{1}' is invalid. Take rates for all features in the pack must be equivalent.";

        public FeaturePackEquivalentTakeRateValidator()
        {
            RuleFor(p => p)
                .Must(p => p.AllPacks.IsFeatureTakeRateEquivalentToPack(p))
                .WithMessage(Message,
                    p => p.PackName,
                    p => p.Model)
                .WithState(p => new ValidationState(ValidationRule.TakeRateForPackFeaturesShouldBeEquivalent, p));
        }
    }
    public class OptionItemGreaterThanOrEqualToPackValidator : AbstractValidator<FeaturePack>
    {
        private const string Message = "Optional feature(s) for model '{0}' in pack '{1}' are invalid. The take rate for an option plus the take rate for the feature pack exceeds 100%";
        
        public OptionItemGreaterThanOrEqualToPackValidator()
        {
            RuleFor(p => p)
                .Must(p => p.AllPacks.IsFeaturePlusPackTakeLessThan100Percent(p))
                .WithMessage(Message,
                    p => p.Model,
                    p => p.PackName)
                .WithState(p => new ValidationState(ValidationRule.OptionalPackFeaturesGreaterThanOrEqualToPack, p));
        }
    }
    public class TakeRateForFeaturePackValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateForFeaturePackValidator()
        {
            RuleForEach(d => d.FeaturePacks)
                .SetValidator(new FeaturePackEquivalentTakeRateValidator());
            RuleForEach(d => d.FeaturePacks)
                .SetValidator(new OptionItemGreaterThanOrEqualToPackValidator());
        }
        
    }
}
