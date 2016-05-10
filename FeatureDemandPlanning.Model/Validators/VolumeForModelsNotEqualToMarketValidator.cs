using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class VolumeForModelsNotEqualToMarketValidator : AbstractValidator<RawTakeRateData>
    {
        private const string Message =
            "Total volume for models of {0} is not equal to the volume for market '{1}' of {2}.";

        public VolumeForModelsNotEqualToMarketValidator()
        {
            RuleFor(d => d)
                .Must(BeEqualToMarketVolume)
                .WithMessage(Message,
                    GetModelVolume,
                    dataItems => dataItems.SummaryItems.First().Market,
                    GetMarketVolume)
                .WithState(d => new ValidationState(ValidationRule.VolumeForModelsGreaterThanMarket)
                {
                    TakeRateId = d.SummaryItems.First().FdpVolumeHeaderId,
                    MarketId = d.SummaryItems.First().MarketId,
                    Volume = (int)GetMarketVolume(d),
                    PercentageTakeRate = (decimal)GetMarketPercentageTake(d)
                });
        }
        private static object GetMarketVolume(RawTakeRateData rawData)
        {
            return GetModelVolume(rawData);
        }
        private static object GetMarketPercentageTake(RawTakeRateData rawData)
        {
            var market = rawData.SummaryItems.First(s => s.ModelId.HasValue && s.FdpModelId.HasValue);

            return market != null ? market.PercentageTakeRate : 0;
        }
        private static object GetModelVolume(RawTakeRateData rawData)
        {
            return rawData.SummaryItems.Where(s => s.ModelId.HasValue).Sum(s => s.Volume);
        }
        private static bool BeEqualToMarketVolume(RawTakeRateData rawData)
        {
            return ((int)GetMarketVolume(rawData)) == ((int)GetModelVolume(rawData));
        }
    }
}
