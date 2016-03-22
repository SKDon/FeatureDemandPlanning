namespace FeatureDemandPlanning.Model
{
    public class ImportSummary
    {
        public int TotalLines { get; set; }
        public int FailedLines { get; set; }
        public int SuccessLines { get; set; }
        public string ImportFileName { get; set; }
        public int TotalErrors { get; set; }
    }
}
