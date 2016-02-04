using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class UserMarketMapping
    {
        public int FdpUserId { get; set; }
        public int FdpUserMarketMappingId { get; set; }

        public int MarketId { get; set; }
        public UserAction Action { get { return FdpUserActionId; } set { FdpUserActionId = value; } }
        public UserAction FdpUserActionId { get; set; }
        public string Market { get; set; }
    }
}
