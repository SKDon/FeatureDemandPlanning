namespace FeatureDemandPlanning.Model
{
    public class AllModelMix
    {
        public int ModelVolume { get; set; }
        public decimal ModelMix { get; set; }
        public bool HasModelMixChanged { get; set; }
        public bool HasModelVolumeChanged { get; set; }

        public bool IsModelMix { get { return true; } }
        public bool IsMarketReview { get; set; }
    }
}
