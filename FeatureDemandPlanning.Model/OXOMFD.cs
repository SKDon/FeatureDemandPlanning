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
    public class MFD : BusinessObject
    {
        public string JLRFamilyCode { get; set; }
        public string JLRFamilyName { get; set; }
        public string LegacyFamilyCode { get; set; }
        public string LegacyFamilyName { get; set; }
        public string JLRFeatureCode { get; set; }
        public string JLRFeatureName { get; set; }
        public string LegacyOACode { get; set; }
        public string LegacyOAName { get; set; }
        public string LegacyWERSCode { get; set; }
        public string LegacyWERSName { get; set; }
        public bool IsLessFeature { get; set; }

        // A blank constructor
        public MFD() { ;}
    }

    [Serializable]
    public class JMFD : BusinessObject
    {
        private string _featureSubGroup;

        public string FeatureCode { get; set; }
        public string OACode { get; set; }
        public string Description { get; set; }
        public string LongDescription { get; set; }
        public string VistaVisibility { get; set; }     
        public string EFG { get; set; }
        public string EFGDescription { get; set; }
        public string FeatureGroup { get; set; }
        public string FeatureSubGroup {
            get
            {
                return String.IsNullOrEmpty(_featureSubGroup) ? "NA" : _featureSubGroup;
                    
            }
            set
            {
                _featureSubGroup = value;
            }
        }
        public string ConfiguratorGroup { get; set; }
        public string ConfiguratorSubGroup { get; set; }
        public string JaguarDescription { get; set; }
        public string LandroverDescription { get; set; }
        public string Applicability { get; set; }

        // A blank constructor
        public JMFD() { ;}
    }

}