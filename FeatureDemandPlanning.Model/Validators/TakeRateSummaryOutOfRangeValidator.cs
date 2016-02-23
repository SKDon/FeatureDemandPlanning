using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateSummaryOutOfRangeValidator : AbstractValidator<RawTakeRateSummaryItem>
    {
        private const string LowerLimitMessage =
            "Take rate of {0:P} is invalid for model '{1}'. Take rates should not be less than 0 %.";
        private const string UpperLimitMessage =
            "Take rate of {0:P} is invalid for model '{1}'. Take rates should not be more than 100 %.";

        public TakeRateSummaryOutOfRangeValidator()
        {
            RuleFor(d => d.PercentageTakeRate)
                .Cascade(CascadeMode.StopOnFirstFailure)
                .GreaterThanOrEqualTo(0)
                .WithMessage(
                    LowerLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.Model)
                .LessThanOrEqualTo(1)
                .WithMessage(
                    UpperLimitMessage,
                    d => d.PercentageTakeRate,
                    d => d.Model)
                .WithState(d => new ValidationState(ValidationRule.TakeRateOutOfRange)
                {
                    MarketId = d.MarketId,
                    ModelId = d.ModelId,
                    FdpModelId = d.FdpModelId,
                    Volume = d.Volume,
                    PercentageTakeRate = d.PercentageTakeRate
                });
        }
    }
}
