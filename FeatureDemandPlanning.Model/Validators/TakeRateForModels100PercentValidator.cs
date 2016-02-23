using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateForModels100PercentValidator : AbstractValidator<RawTakeRateData>
    {
        private const string Message =
            "Take Rate for models of {0:P} for market should equal 100 %.";

        public TakeRateForModels100PercentValidator(IDataContext context)
        {
            RuleFor(d => d)
                .Must(BeEqualTo100Percent)
                .WithMessage(Message,
                    GetModelTakeRate)
                .WithState(d => new ValidationState(ValidationRule.TotalTakeRateForModelsOutOfRange)
                {
                    MarketId = d.SummaryItems.First().MarketId,
                    PercentageTakeRate = (int)GetModelTakeRate(d),
                    Volume = (int)GetModelVolume(d)
                });
        }
        private static object GetModelTakeRate(RawTakeRateData rawData)
        {
            return rawData.SummaryItems.Where(s => s.ModelId.HasValue || s.FdpModelId.HasValue).Sum(s => s.PercentageTakeRate);
        }
        private static object GetModelVolume(RawTakeRateData rawData)
        {
            return rawData.SummaryItems.Where(s => s.ModelId.HasValue || s.FdpModelId.HasValue).Sum(s => s.Volume);
        }
        private static bool BeEqualTo100Percent(RawTakeRateData rawData)
        {
            return (decimal)GetModelTakeRate(rawData) == 1;
        }
    }
}


