using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class MarketMapping
    {
        public int? FdpMarketMappingId { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        
        public string ImportMarket { get; set; }
        public int? MappedMarketId { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public bool? IsGlobalMapping { get; set; }

        public Market MappedMarket { get; set; }

        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public bool IsActive { get; set; }

        public MarketMapping()
        {
            MappedMarket = new EmptyMarket();
            IsGlobalMapping = false;
            IsActive = true;
        }

        
    }
}
