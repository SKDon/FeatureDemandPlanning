namespace FeatureDemandPlanning.Model
{
    public class RawTakeRateSummaryItem
    {
        public int FdpVolumeHeaderId { get; set; }
        public int FdpTakeRateSummaryId { get; set; }
        public int? FdpChangesetDataItemId { get; set; }
        public int MarketId { get; set; }
        public string Market { get; set; }
        public int MarketGroupId { get; set; }
        public string MarketGroup { get; set; }
        public int? ModelId { get; set; }
        public int? FdpModelId { get; set; }
        public string Model { get; set; }
        public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }

        public string ModelIdentifier
        {
            get
            {
                if (ModelId.HasValue)
                {
                    return "O" + ModelId;
                }
                if (FdpModelId.HasValue)
                {
                    return "F" + FdpModelId;
                }
                
                return string.Empty;
            }
        }
    }
}
