using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Filters
{
    public class TakeRateFilter : ProgrammeFilter
    {
        public int? TakeRateId { get; set; }
        public int? TakeRateDataItemId { get; set; }
        public int? TakeRateStatusId { get; set; }
        public TakeRateDataItemAction Action { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public IEnumerable<FdpModel> Models { get; set; }
        public int? ModelId { get; set; }
        public int? FdpModelId { get; set; }
        public int? FeatureId { get; set; }
        public int? FdpFeatureId { get; set; }
        public int? FeaturePackId { get; set; }
        public MarketReviewStatus MarketReviewStatus { get; set; }
        public string Filter { get; set; }

        // For updating take rate and volume for summary items
        public int? NewTakeRate { get; set; }
        public int? NewVolume { get; set; }
        
        // When updating comments for items
        public string Comment { get; set; }

        public TakeRateFilter()
        {
            Mode = TakeRateResultMode.PercentageTakeRate;
            Models = Enumerable.Empty<FdpModel>();
        }

        public static TakeRateFilter FromTakeRateDocument(ITakeRateDocument document)
        {
            var filter = new TakeRateFilter()
            {
                ProgrammeId = document.Vehicle.ProgrammeId,
                Gateway = document.Vehicle.Gateway
            };

            if (!(document.UnderlyingOxoDocument is EmptyOxoDocument))
                filter.DocumentId = document.UnderlyingOxoDocument.Id;

            if (!(document.Market is EmptyMarket))
                filter.MarketId = document.Market.Id;

            if (!(document.MarketGroup is EmptyMarketGroup))
                filter.MarketGroupId = document.MarketGroup.Id;

            if (!(document.Vehicle is EmptyVehicle))
                filter.Models = document.Vehicle.AvailableModels;

            filter.Mode = document.Mode;

            return filter;
        }
        public static TakeRateFilter FromTakeRateId(int takeRateId)
        {
            return new TakeRateFilter
            {
                DocumentId = takeRateId
            };
        }
        public static TakeRateFilter FromTakeRateParameters(TakeRateParameters parameters)
        {
            var filter = new TakeRateFilter
            {
                TakeRateId = parameters.TakeRateId,
                DocumentId = parameters.DocumentId,
                TakeRateDataItemId = parameters.TakeRateDataItemId,
                TakeRateStatusId = parameters.TakeRateStatusId,
                Mode = parameters.Mode,
                Action = parameters.Action,
                MarketGroupId = parameters.MarketGroupId,
                MarketId = parameters.MarketId,
                Comment = parameters.Comment,
                MarketReviewStatus = parameters.MarketReviewStatus,
                Filter = parameters.Filter
            };

            if (!string.IsNullOrEmpty(parameters.ModelIdentifier))
            {
                if (parameters.ModelIdentifier.StartsWith("O"))
                {
                    filter.ModelId = int.Parse(parameters.ModelIdentifier.Substring(1));
                }
                else
                {
                    filter.FdpModelId = int.Parse(parameters.ModelIdentifier.Substring(1));
                }
            }

            if (string.IsNullOrEmpty(parameters.FeatureIdentifier)) return filter;

            if (parameters.FeatureIdentifier.StartsWith("O"))
            {
                filter.FeatureId = int.Parse(parameters.FeatureIdentifier.Substring(1));
            }
            else if (parameters.FeatureIdentifier.StartsWith("P"))
            {
                filter.FeaturePackId = int.Parse(parameters.FeatureIdentifier.Substring(1));
            }
            else
            {
                filter.FdpFeatureId = int.Parse(parameters.FeatureIdentifier.Substring(1));
            }

            return filter;
        }
    }
}
