using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.ViewModel;

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

        // Additional paging support for take rate files
        public int TotalPages { get; set; }
        public int TotalRecords { get; set; }
        public int TotalDisplayRecords { get; set; }

        public TakeRateFilter()
        {
            Mode = TakeRateResultMode.PercentageTakeRate;
            Models = Enumerable.Empty<FdpModel>();
        }

        public static TakeRateFilter FromTakeRateViewModel(TakeRateViewModel takeRateViewModel)
        {
            var filter = new TakeRateFilter()
            {
                ProgrammeId = takeRateViewModel.Document.UnderlyingOxoDocument.ProgrammeId,
                Gateway = takeRateViewModel.Document.UnderlyingOxoDocument.Gateway
            };

            if (!(takeRateViewModel.Document.UnderlyingOxoDocument is EmptyOxoDocument))
            {
                filter.TakeRateId = takeRateViewModel.Document.TakeRateId;
                filter.DocumentId = takeRateViewModel.Document.UnderlyingOxoDocument.Id;
            }

            if (!(takeRateViewModel.Document.Market is EmptyMarket))
                filter.MarketId = takeRateViewModel.Document.Market.Id;

            if (!(takeRateViewModel.Document.MarketGroup is EmptyMarketGroup))
                filter.MarketGroupId = takeRateViewModel.Document.MarketGroup.Id;

            if (!(takeRateViewModel.Document.Vehicle is EmptyVehicle))
                filter.Models = takeRateViewModel.Document.Vehicle.AvailableModels;

            filter.Mode = takeRateViewModel.Document.Mode;

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
                Filter = parameters.Filter,
                PageSize = parameters.PageSize,
                PageIndex = parameters.PageIndex
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
