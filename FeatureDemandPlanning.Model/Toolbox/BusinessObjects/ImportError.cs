using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ImportError
    {
        public int FdpImportId { get; set; }
        public int ImportQueueId { get; set; }
        public int FdpImportErrorId { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public int LineNumber { get; set; }
        public int FdpImportErrorTypeId { get; set; }
        public bool IsExcluded { get; set; }

        public ImportExceptionType ErrorType
        {
            get
            {
                return (ImportExceptionType)FdpImportErrorTypeId;
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
                LineNumber.ToString(), 
                ErrorTypeDescription,
                ErrorMessage,
                ErrorOn.ToString("dd/MM/yyyy HH:mm")
            };
        }
    }
}
