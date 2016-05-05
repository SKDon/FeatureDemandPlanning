using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public abstract class EfgValidatorBase : AbstractValidator<EfgGrouping>
    {
        protected static object GetPercentageTakeRate(EfgGrouping group)
        {
            return group.TotalPercentageTakeRate;
        }
        protected static string GetModel(EfgGrouping group)
        {
            return group.Model;
        }
        protected static string GetExclusiveFeatureGroup(EfgGrouping group)
        {
            return group.ExclusiveFeatureGroup;
        }
    }
    public class EfgStandardFeatureValidator : EfgValidatorBase
    {
        private const string Message = "Total take rate of {0:P} in model '{1}' for all features in exclusive feature group '{2}' is invalid. All features should add up to 100 % as group contains a standard feature.";

        public EfgStandardFeatureValidator()
        {
            RuleFor(d => d)
                .Must(Have100PercentTakeForExclusiveFeatureGroup)
                .WithMessage(Message,
                    GetPercentageTakeRate,
                    GetModel,
                    GetExclusiveFeatureGroup)
                .WithState(g => new ValidationState(ValidationRule.TakeRateForEfgShouldEqualTo100Percent, g));
        }
        private static bool Have100PercentTakeForExclusiveFeatureGroup(EfgGrouping group)
        {
            return !@group.HasStandardFeatureInGroup ||
                          (@group.HasStandardFeatureInGroup && @group.TotalPercentageTakeRate == 1);
        }
    }
    public class EfgNonStandardFeatureValidator : EfgValidatorBase
    {
        private const string Message = "Total take rate of {0:P} in model '{1}' for all features in exclusive feature group '{2}' is invalid. All features must be less than or equal to 100 %.";

        public EfgNonStandardFeatureValidator()
        {
            RuleFor(d => d)
                .Must(HaveLessThanOrEqualTo100PercentTakeForExclusiveFeatureGroup)
                .WithMessage(Message,
                    GetPercentageTakeRate,
                    GetModel,
                    GetExclusiveFeatureGroup)
                .WithState(g => new ValidationState(ValidationRule.TakeRateForEfgShouldbeLessThanOrEqualTo100Percent, g));
        }
        private static bool HaveLessThanOrEqualTo100PercentTakeForExclusiveFeatureGroup(EfgGrouping group)
        {
            return group.HasStandardFeatureInGroup ||
                   (!group.HasStandardFeatureInGroup && group.TotalPercentageTakeRate <= 1);

        }
    }
    public class EfgOnlyOneValidator : EfgValidatorBase
    {
        private const string Message = "Exclusive feature group '{0}' in model '{1}' is invalid. Only one feature can have a take rate";

        public EfgOnlyOneValidator()
        {
            RuleFor(g => g)
                .Must(OneFeatureOnlyWithTakeRate)
                .WithMessage(Message,
                    GetExclusiveFeatureGroup,
                    GetModel
                    )
                .WithState(g => new ValidationState(ValidationRule.OnlyOneFeatureInEfg, g));
        }
        private static bool OneFeatureOnlyWithTakeRate(EfgGrouping group)
        {
            return group.NumberOfItemsWithTakeRate == 1;
        }
    }
    public class TakeRateForEfgValidator : AbstractValidator<RawTakeRateData>
    {
        public TakeRateForEfgValidator()
        {
            RuleForEach(d => d.EfgGroupings)
                .SetValidator(new EfgStandardFeatureValidator());

            RuleForEach(d => d.EfgGroupings)
                .SetValidator(new EfgNonStandardFeatureValidator());

            //RuleForEach(d => d.EfgGroupings)
            //    .SetValidator(new EfgOnlyOneValidator());
        }
    }
}
