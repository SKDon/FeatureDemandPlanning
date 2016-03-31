using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class ImportStatus
    {
        public enums.ImportStatus ImportStatusCode { get; set; }
        public string Status { get; set; }
        public string Description { get; set; }
        public int NumberOfRecordsProcessed { get; set; }
        public int NumberOfRecordsFailed { get; set; }

        public ImportStatus()
        {
            ImportStatusCode = enums.ImportStatus.NotSet;
        }
    }
}
