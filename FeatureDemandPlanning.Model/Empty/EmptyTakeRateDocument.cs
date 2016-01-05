using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model
{
    public class EmptyTakeRateDocument : TakeRateDocument
    {
        public EmptyTakeRateDocument()
        {
            UnderlyingOxoDocument = new EmptyOxoDocument();
            Vehicle = new EmptyVehicle();
            Market = new EmptyMarket();
            MarketGroup = new EmptyMarketGroup();
        }
    }
}
