namespace FeatureDemandPlanning.Model
{
    public class ValidationResult
    {
        public int MarketId { get; set; }
        public string ModelIdentifier { get; set; }
        public string FeatureIdentifier { get; set; }
        public string Message { get; set; }
    }
}
