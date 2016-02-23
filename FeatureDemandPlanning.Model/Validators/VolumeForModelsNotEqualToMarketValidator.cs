using System.Linq;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

namespace FeatureDemandPlanning.Model.Validators
{
    public class VolumeForModelsNotEqualToMarketValidator : AbstractValidator<RawTakeRateData>
    {
        private const string Message =
            "Total volume for models of {0} is greater than the volume for market '{1}' of {2}.";

        public VolumeForModelsNotEqualToMarketValidator(IDataContext context)
        {
            RuleFor(d => d)
                .Must(BeEqualToMarketVolume)
                .WithMessage(Message,
                    GetModelVolume,
                    dataItems => dataItems.SummaryItems.First().Market,
                    GetMarketVolume);
        }
        private static object GetMarketVolume(RawTakeRateData rawData)
        {
            var market = rawData.SummaryItems.First(s => !s.ModelId.HasValue && !s.FdpModelId.HasValue);

            return market != null ? market.Volume : 0;
        }
        private static object GetModelVolume(RawTakeRateData rawData)
        {
            return rawData.SummaryItems.Where(s => s.ModelId.HasValue || s.FdpModelId.HasValue).Sum(s => s.Volume);
        }
        private static bool BeEqualToMarketVolume(RawTakeRateData rawData)
        {
            return ((int)GetMarketVolume(rawData)) <= ((int)GetModelVolume(rawData));
        }
    }
}
