using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using System.Web.Script.Serialization;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Model
{
    [Serializable]
    public class Market : BusinessObject
    {
        [Required]
        [MaxLength(500)]
        public string Name { get; set; }
        [Required]
        [StringLength(3)]
        public string WHD { get; set; }
        [StringLength(5)]
        public string PAR_X { get; set; }
        [StringLength(5)]
        public string PAR_L { get; set; }
        [RegularExpression(@"^\d+$", ErrorMessage = "Terrority should be a numerical value.")]
        [StringLength(5, ErrorMessage = "Terrority should be a 5 digits value.")]
        public string Territory { get; set; }
        public string WERSCode { get; set; }
        public string Brand { get; set; }
        public string GroupName { get; set; }
        public string SubRegion { get; set; }
        public int GroupId { get; set; }
        public int SubRegionOrder { get; set; }
        public int VariantCount { get; set; }

        // A blank constructor
        public Market() { ;}
    }

    public class MarketComparer : IEqualityComparer<Market>
    {
        public bool Equals(Market x, Market y)
        {
            return x.Id == y.Id;
        }

        public int GetHashCode(Market obj)
        {
            return obj.GetHashCode();
        }
    }
}