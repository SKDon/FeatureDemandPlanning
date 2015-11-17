using FeatureDemandPlanning.Model.Empty;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class TrimMapping
    {
        public int FdpTrimMappingId { get; set; }

        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public string ImportTrim { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public int TrimId { get; set; }

        public ModelTrim Trim { get; set; }

        public TrimMapping()
        {
            Trim = new EmptyModelTrim();
        }
    }
}
