using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class ImportQueueFilter : FilterBase
    {
        public int? ImportQueueId { get; set; }
        public int? ExceptionId { get; set; }
        public ImportAction Action { get; set; }
        public enums.ImportStatus ImportStatus { get; set; }
        public enums.ImportExceptionType ExceptionType { get; set;}
        public bool? IsActive { get; set; }
        public string ErrorMessage { get; set; }
        
        public ImportQueueFilter()
        {
            Action = ImportAction.NotSet;
            ImportStatus = enums.ImportStatus.NotSet;
            ExceptionType = enums.ImportExceptionType.NotSet;
        }
        public ImportQueueFilter(int importQueueId) : this()
        {
            ImportQueueId = importQueueId;
        }
        public static ImportQueueFilter FromExceptionId(int exceptionId)
        {
            return new ImportQueueFilter()
            {
                ExceptionId = exceptionId,
                Action = ImportAction.Exception
            };
        }
        public static ImportQueueFilter FromParameters(ImportParameters Parameters)
        {
            return new ImportQueueFilter()
            {
                ImportQueueId = Parameters.ImportQueueId
            };
        }
    }
}
