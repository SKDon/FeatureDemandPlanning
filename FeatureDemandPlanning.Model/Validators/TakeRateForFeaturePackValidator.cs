using System.Collections;
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
                .Must(p => p.DistinctTakeRates() <= 1)
                .WithMessage(Message,
                    p => p.PackName,
                    p => p.Model)
                .WithState(p => new ValidationState(ValidationRule.TakeRateForPackFeaturesShouldBeEquivalent, p));
        }
    }
    public class OptionItemGreaterThanOrEqualToPackValidator : AbstractValidator<FeaturePack>
    {
        private const string Message = "Optional feature(s) '{0}' for model '{1}' is in pack '{2}' are invalid. Take rates for options available in a feature pack cannot be less than the take rate for the feature pack.";
        private IList<string> _invalidOptions = new List<string>(); 

        public OptionItemGreaterThanOrEqualToPackValidator()
        {
            RuleFor(p => p)
                .Must(AllOptionalFeaturesTakeRateGreaterThanOrEqualToPack)
                .WithMessage(Message,
                    p => _invalidOptions.ToCommaSeperatedList(),
                    p => p.Model,
                    p => p.PackName)
                .WithState(p => new ValidationState(ValidationRule.OptionalPackFeaturesGreaterThanOrEqualToPack, p));
        }

        public bool AllOptionalFeaturesTakeRateGreaterThanOrEqualToPack(FeaturePack pack)
        {
            _invalidOptions = new List<string>();
            var optionalFeatures = pack.PackItems.Where(d => d.IsOptionalFeatureInGroup && d.FeatureId.HasValue);
            foreach (var optionalFeature in optionalFeatures)
            {
                if (optionalFeature.PercentageTakeRate >= pack.PackPercentageTakeRate &&
                    optionalFeature.Volume >= pack.PackVolume) continue;
                
                _invalidOptions.Add(optionalFeature.FeatureDescription);

                return false;
            }
            return true;
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
