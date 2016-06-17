using System;

namespace FeatureDemandPlanning.Model
{
    public class ModelTakeRateSummary
    {
        public string StringIdentifier { get; set; }
        public bool IsFdpModel { get; set; }
        public int Volume { get; set; }
        public decimal PercentageOfFilteredVolume { get; set; }
    }
}
