using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class FdpChangeset
    {
        public int? FdpChangesetId { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsSaved { get; set; }

        public IList<DataChange> Changes { get; set; }

        public FdpChangeset()
        {
            Changes = new List<DataChange>();
        }
    }
}
