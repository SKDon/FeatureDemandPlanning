using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.Models
{
    public class ImportExceptionsParameterModel : JQueryDataTableParameters
    {
        public int? ImportQueueId { get; set; }
        public ImportExceptionType ExceptionType { get; set; }
        public string FilterMessage { get; set; }

        public ImportExceptionsParameterModel()
        {
            ExceptionType = ImportExceptionType.NotSet;
            FilterMessage = string.Empty;
        }
    }
}