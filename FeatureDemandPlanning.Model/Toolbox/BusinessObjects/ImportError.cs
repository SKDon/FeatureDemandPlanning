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

        public int LineNumber { get; set; }
        public int FdpImportErrorTypeId { get; set; }
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
    }
}
