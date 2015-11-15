namespace FeatureDemandPlanning.Model.Parameters
{
    public class ForecastParameters : JQueryDataTableParameters
    {
        public int? ForecastId { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public string FilterMessage { get; set; }

        public ForecastParameters()
        {
            FilterMessage = string.Empty;
        }
        public bool HasForecastId()
        {
            return ForecastId.HasValue;
        }
        public bool HasProgrammeId()
        {
            return ProgrammeId.HasValue;
        }
        public bool HasGateway()
        {
            return !string.IsNullOrEmpty(Gateway);
        }
    }
}
