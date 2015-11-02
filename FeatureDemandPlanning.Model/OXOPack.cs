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
    public class Pack : BusinessObject
    {
        public int DocId { get; set; }
        public int ProgrammeId { get; set; }
        [MaxLength(500)]
        public string Name { get; set; }
        [MaxLength(500)]
        public string ExtraInfo { get; set; }
        [MaxLength(50)]
        public string FeatureCode { get; set; }
        [MaxLength(50)]
        public string OACode { get; set; }


        public IEnumerable<Feature> Features{ get; set; }

        // A blank constructor
        public Pack() { ;}
    }


    [Serializable]
    public class PackFeature : BusinessObject
    {

        [Required]
        public int DocId { get; set; }        
        [Required]
        public int ProgrammeId { get; set; }        
        [Required]
        public int PackId { get; set; }
        [MaxLength(500)]
        public string PackName { get; set; }
        [MaxLength(500)]
        public string PackExtraInfo { get; set; }
        [MaxLength(50)]
        public string PackFeatureCode { get; set; }
        [MaxLength(500)]
        public string SystemDescription { get; set; }
        [MaxLength(500)]
        public string BrandDescription { get; set; }
        [MaxLength(50)]
        public string OACode { get; set; }
                
        // A blank constructor
        public PackFeature() { ;}
    }


}