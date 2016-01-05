using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Model
{
    public class MarketGroup : BusinessObject
    {
        [Required]
        [StringLength(500)]
        public string GroupName { get; set; }
        public string SubGroupName { get; set; }
        public string ExtraInfo { get; set; }
        public string Type { get; set; }
        public int ProgrammeId { get; set; }
        public int VariantCount { get; set; }

        public List<Market> Markets { get; set; }
        

        // A blank constructor
        public MarketGroup() {;}


    }
}