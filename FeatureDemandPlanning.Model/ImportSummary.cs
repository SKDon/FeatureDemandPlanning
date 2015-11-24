using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class ImportSummary
    {
        public int TotalLines { get; set; }
        public int FailedLines { get; set; }
        public int SuccessLines { get; set; }
        public string ImportFileName { get; set; }
    }
}
