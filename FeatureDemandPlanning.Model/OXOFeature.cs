
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;

namespace FeatureDemandPlanning.Model
{
    public class Feature : BusinessObject
    {
        public string SystemDescription { get; set; }
        public string BrandDescription { get; set; }
        public string Notes { get; set; }
        public string FeatureCode { get; set; }
        public string OACode { get; set; }

        public string MFDJLRCode { get; set; } 
        public string MFDEFG { get; set; } 
        public string WERS { get; set; }
        public string FeatureGroup { get; set; }
        public string FeatureSubGroup { get; set; }
        public int GroupOrder { get; set; }

        public int PackId { get; set; }
        public string PackName { get; set; }
        public string PackFeatureCode { get; set; }
        public string Comment { get; set; }
        public string RuleText { get; set; }

        // A blank constructor
        public Feature() {;}
    }


    public class RuleTooltip
    {
        public int RuleId { get; set; }
        public string RuleResponse { get; set; }
        public string RuleReason { get; set; }
        public bool RuleApproved { get; set; }
        public string RuleCategory { get; set; }
        public bool RuleActive { get; set; }


        public RuleTooltip() { ;}
    }

    public class FeatureComment
    {
        public int progid { get; set; }
        public int featureid { get; set; }
        public string comment { get; set; }
    }

    public class FeatureGroup
    {
        public int GroupId { get; set; }
        public string FeatureGroupName { get; set; }
        public string FeatureSubGroup { get; set; }
    }

    public class FeatureLookup
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string Descr { get; set; }
    }
}
