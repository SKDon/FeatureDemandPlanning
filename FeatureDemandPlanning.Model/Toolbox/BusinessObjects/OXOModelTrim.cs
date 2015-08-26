
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ModelTrim : BusinessObject
    {
        public string TypeName { get { return "ModelTrim"; } }
        public int ProgrammeId { get; set; }
        public string Name { get; set; }
        public string Abbreviation { get; set; }
        public string Level { get; set; }
        public string DPCK { get; set; }
           
        // A blank constructor
        public ModelTrim() {;}
    }
}