using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;

namespace FeatureDemandPlanning.Model
{
    public class OXORuleResult : BusinessObject
    {
            public int OXODocId { get; set; }
            public int ProgrammeId { get; set; }
            public string ObjectLevel { get; set; }
            public int ObjectId { get; set; }
            public int RuleId { get; set; }
            public int ModelId { get; set; }
            public string Model { get; set; }
            public string CoA { get; set; }
            public string FeatureGroup { get; set; }
            public string RuleCategory { get; set; }
            public string Owner { get; set; }
            public string RuleResponse { get; set; }
            public bool RuleResult { get; set; }
            public string ObjectName { get; set; }   

        // A blank constructor
        public OXORuleResult() {;}
    }
}