using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.BusinessObjects
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
            ImportStatusCode = enums.ImportStatus.Success;
        }
    }
}
