namespace FeatureDemandPlanning.Model
{
    public class EmptyVolume : Volume
    {
        public EmptyVolume()
        {
            Document = new EmptyOxoDocument();
            Vehicle = new EmptyVehicle();
            Market = new EmptyMarket();
            MarketGroup = new EmptyMarketGroup();
        }
    }
}
