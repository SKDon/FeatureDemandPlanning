namespace FeatureDemandPlanning.Model
{
    public class FdpModel : Model
    {
        public int? FdpModelId { get; set; }
        public string StringIdentifier { get; set; }

        public int? Volume { get; set; }
        public decimal? PercentageTakeRate { get; set; }
    }
}
