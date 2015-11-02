using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;

namespace FeatureDemandPlanning.Model
{
    public class RuleFeature : BusinessObject
    {
            public int RuleId { get; set; }
            public int ProgrammeId { get; set; }
            public int FeatureId { get; set; }

           
        // A blank constructor
        public RuleFeature() {;}
    }
}