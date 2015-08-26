using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Schematron
{
    public class ValidationResult
    {
        public string DocId { set; get; }
        public string ProgId { set; get; }
        public string ModelId { set; get; }
        public string Model { set; get; }
        public string Source { set; get; }
        public string RuleId { set; get; }
        public string Area { set; get; }
        public string Text { set; get; }
        public string Type { set; get; }
        public string Owner { set; get; }
        public bool Pass {
            get{ return (Type == "Assert" ? false : true); } 
        }

        public ValidationResult(string docId, string progId, string modelId, string model, string source, string ruleId, string area, string text, string type, string owner, string pass)
        {
            this.DocId = docId;
            this.ProgId = ProgId;
            this.ModelId = modelId;
            this.Model = model;
            this.Source = source;
            this.RuleId = ruleId;
            this.Area = area;
            this.Text = text;
            this.Type = type;
            this.Owner = owner;
        }
    }
}
