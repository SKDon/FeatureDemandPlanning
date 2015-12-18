using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateSummary
    {
        public int TakeRateId { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public int OxoDocId { get; set; }
        public string OxoDocument { get; set; }

        public int FdpTakeRateStatusId { get; set; }
        public string Status { get; set; }
        public string StatusDescription { get; set; }

        public string[] ToJQueryDataTableResult()
        {
            return new string[] 
            { 
                TakeRateId.ToString(),
                CreatedOn.ToString("dd/MM/yyyy"),
                CreatedBy,
                OxoDocument,
                Status,
                UpdatedOn.HasValue ? UpdatedOn.Value.ToString("dd/MM/yyyy HH:mm") : "-",
                !string.IsNullOrEmpty(UpdatedBy) ? UpdatedBy : "-",
                OxoDocId.ToString()
            };
        }
    }
}
