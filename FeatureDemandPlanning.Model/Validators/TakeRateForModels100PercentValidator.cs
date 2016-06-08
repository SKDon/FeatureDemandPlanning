using System;
using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateForModels100PercentValidator : AbstractValidator<RawTakeRateData>
    {
        private const string Message =
            "Derivative Mix equals {0:P}. It should equal 100%";

        public TakeRateForModels100PercentValidator()
        {
            RuleFor(d => d)
                .Must(BeEqualTo100Percent)
                .WithMessage(Message,
                    GetModelTakeRate)
                .WithState(d => new ValidationState(ValidationRule.TotalTakeRateForModelsOutOfRange)
                {
                    TakeRateId = d.DataItems.First().FdpVolumeHeaderId,
                    MarketId = d.SummaryItems.First().MarketId,
                    PercentageTakeRate = (decimal)GetModelTakeRate(d),
                    Volume = (int)GetModelVolume(d)
                });
        }
        private static object GetModelTakeRate(RawTakeRateData rawData)
        {
            return Math.Round(rawData.SummaryItems.Where(s => s.ModelId.HasValue || s.FdpModelId.HasValue).Sum(s => s.PercentageTakeRate), 2);
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


