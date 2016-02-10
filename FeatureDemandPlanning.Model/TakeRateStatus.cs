namespace FeatureDemandPlanning.Model
{
    public class TakeRateStatus
    {
        public int StatusId { get; set; }
        public string Status { get; set; }
        public string Description { get; set; }
        public Enumerations.TakeRateStatus StatusCode { get { return (Enumerations.TakeRateStatus) StatusId; } }
    }
}
