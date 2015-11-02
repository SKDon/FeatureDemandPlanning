using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class ImportParameters : JQueryDataTableParameters
    {
        public int? ImportQueueId { get; set; }
        public int? ProgrammeId { get; set; }
        public string FilterMessage { get; set; }

        public ImportParameters()
        {
            FilterMessage = string.Empty;
        }
        public bool HasImportQueueId()
        {
            return ImportQueueId.HasValue;
        }
    }
}
