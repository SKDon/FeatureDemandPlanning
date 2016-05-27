namespace FeatureDemandPlanning.Model
{
    public class RawFeaturePackItem
    {
        public int FdpVolumeHeaderId { get; set; }
        public int MarketId { get; set; }
        public int ModelId { get; set; }
        public int FeatureId { get; set; }
        public int FeaturePackId { get; set; }
        public string Feature { get; set; }
        public string FeaturePackName { get; set; }
    }
}
