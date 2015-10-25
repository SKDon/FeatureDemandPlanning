using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.Models
{
    public class ImportExceptionParameters : JQueryDataTableParameters
    {
        public int? ImportQueueId { get; set; }
        public int? ExceptionId { get; set; }
        public ImportExceptionType ExceptionType { get; set; }
        public ImportExceptionAction Action { get; set; }
        public string FilterMessage { get; set; }

        public ImportExceptionParameters()
        {
            ExceptionType = ImportExceptionType.NotSet;
            Action = ImportExceptionAction.NotSet;
            FilterMessage = string.Empty;
        }

        public bool HasImportQueueId()
        {
            return ImportQueueId.HasValue;
        }

        public bool HasExceptionId()
        {
            return ExceptionId.HasValue;
        }

        public bool HasAction()
        {
            return Action != ImportExceptionAction.NotSet;
        }

        public bool HasExceptionType()
        {
            return ExceptionType != ImportExceptionType.NotSet;
        }
    }
}