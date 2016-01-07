using System;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class ImportError
    {
        public int FdpImportId { get; set; }
        public int ImportQueueId { get; set; }
        public int FdpImportErrorId { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public int DocumentId { get; set; }

        public string LineNumber { get; set; }
        public int FdpImportErrorTypeId { get; set; }
        public bool IsActive { get; set; }
        public bool IsExcluded { get; set; }

        public enums.ImportExceptionType ErrorType
        {
            get
            {
                return (enums.ImportExceptionType)FdpImportErrorTypeId;
            }
        }
        public string ErrorTypeDescription { get; set; }
        public DateTime ErrorOn { get; set; }
        public string ErrorMessage { get; set; }

        public string ImportMarket { get; set; }
        public string ImportDerivativeCode { get; set; }
        public string ImportDerivative { get; set; }
        public string ImportTrim { get; set; }
        public string ImportFeatureCode { get; set; }
        public string ImportFeature { get; set; }

        public string[] ToJQueryDataTableResult()
        {
            return new string[] 
            { 
                FdpImportErrorId.ToString(),
                LineNumber.TrimStart('0'), 
                ErrorTypeDescription,
                ErrorMessage,
                ErrorOn.ToString("dd/MM/yyyy HH:mm")
            };
        }
    }
}
