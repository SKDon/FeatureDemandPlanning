using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.Models
{
    public class ImportExceptionParameters : JQueryDataTableParameters
    {
        public int? ImportQueueId { get; set; }
        public int? ExceptionId { get; set; }
        public int? ProgrammeId { get; set; }
        public ImportExceptionType ExceptionType { get; set; }
        public ImportExceptionAction Action { get; set; }
        public string FilterMessage { get; set; }

        public string ImportFeatureCode { get; set; }
        public string FeatureCode { get; set; }
        public string FeatureDescription { get; set; }

        public string ImportTrim { get; set; }
        public int? TrimId { get; set; }
        public string TrimName { get; set; }
        public string TrimAbbreviation { get; set; }
        public string TrimLevel { get; set; }
        public string DPCK { get; set; }

        public string ImportDerivativeCode { get; set; }
        public string DerivativeCode { get; set; }
        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }

        public int? SpecialFeatureTypeId { get; set; }

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