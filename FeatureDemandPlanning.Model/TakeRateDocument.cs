using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateDocument : ITakeRateDocument
    {
        public OXODoc UnderlyingOxoDocument { get; set; }
        public Market Market { get; set; }
        public MarketGroup MarketGroup { get; set; }
        public Vehicle Vehicle { get; set; }
        public TakeRateData TakeRateData { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public int TotalDerivatives { get; set; }
        public IEnumerable<TakeRateSummary> TakeRateSummary { get; set; }

        public TakeRateDocument()
        {
            UnderlyingOxoDocument = new EmptyOxoDocument();
            MarketGroup = new EmptyMarketGroup();
            Market = new EmptyMarket();
            Vehicle = new EmptyVehicle();
            TakeRateData = new EmptyTakeRateData();
            Mode = TakeRateResultMode.PercentageTakeRate;
            TakeRateSummary = new List<TakeRateSummary>();
        }
        public static ITakeRateDocument FromFilter(TakeRateFilter filter)
        {
            var volume = new TakeRateDocument();

            if (filter.OxoDocId.HasValue)
            {
                volume.UnderlyingOxoDocument = new OXODoc() { Id = filter.OxoDocId.Value };
            }

            if (filter.ProgrammeId.HasValue)
            {
                volume.Vehicle = new Vehicle() { ProgrammeId = filter.ProgrammeId.Value, Gateway = filter.Gateway };
            }

            if (filter.MarketGroupId.HasValue)
            {
                volume.MarketGroup = new MarketGroup() { Id = filter.MarketGroupId.Value };
            }

            if (filter.MarketId.HasValue)
            {
                volume.Market = new Market() { Id = filter.MarketId.Value };
            }

            volume.Mode = filter.Mode;

            return volume;
        }
    }
}
