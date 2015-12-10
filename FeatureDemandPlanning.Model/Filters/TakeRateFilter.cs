using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Filters
{
    public class TakeRateFilter : ProgrammeFilter
    {
        public int? TakeRateId { get; set; }
        public int? TakeRateDataItemId { get; set; }
        public int? TakeRateStatusId { get; set; }
        public TakeRateAction Action { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public IEnumerable<Model> Models { get; set; }
        
        public TakeRateFilter()
        {
            Mode = TakeRateResultMode.PercentageTakeRate;
            Models = Enumerable.Empty<Model>();
        }

        public static TakeRateFilter FromVolume(IVolume volume)
        {
            var filter = new TakeRateFilter()
            {
                ProgrammeId = volume.Vehicle.ProgrammeId,
                Gateway = volume.Vehicle.Gateway
            };

            if (!(volume.Document is EmptyOxoDocument))
                filter.OxoDocId = volume.Document.Id;

            if (!(volume.Market is EmptyMarket))
                filter.MarketId = volume.Market.Id;

            if (!(volume.MarketGroup is EmptyMarketGroup))
                filter.MarketGroupId = volume.MarketGroup.Id;

            if (!(volume.Vehicle is EmptyVehicle))
                filter.Models = volume.Vehicle.AvailableModels;

            filter.Mode = volume.Mode;

            return filter;
        }
        public static TakeRateFilter FromTakeRateId(int takeRateId)
        {
            return new TakeRateFilter()
            {
                OxoDocId = takeRateId
            };
        }
        public static TakeRateFilter FromTakeRateParameters(TakeRateParameters parameters)
        {
            return new TakeRateFilter()
            {
                OxoDocId = parameters.TakeRateId,
                TakeRateDataItemId = parameters.TakeRateDataItemId,
                TakeRateStatusId = parameters.TakeRateStatusId,
                Mode = parameters.Mode,
                Action = parameters.Action,
                MarketGroupId = parameters.MarketGroupId,
                MarketId = parameters.MarketId
            };
        }
    }
}
