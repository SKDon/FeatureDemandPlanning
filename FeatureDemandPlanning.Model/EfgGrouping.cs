namespace FeatureDemandPlanning.Model
{
    public class EfgGrouping
    {
        public int TakeRateId { get; set; }
        public int MarketId { get; set; }
        public string Market { get; set; }
        public int ModelId { get; set; }
        public string Model { get; set; }
        public string ExclusiveFeatureGroup { get; set; }
        public decimal TotalPercentageTakeRate { get; set; }
        public bool HasStandardFeatureInGroup { get; set; }
        public int NumberOfItemsWithTakeRate { get; set; }

        public override string ToString()
        {
            return string.Format("Model: {0}, EFG: {1}, Take % {2}, Std {3}", ModelId, ExclusiveFeatureGroup,
                TotalPercentageTakeRate, HasStandardFeatureInGroup);
        }
    }
}
