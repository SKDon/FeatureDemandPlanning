using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ImportType
    {
        public enums.ImportType ImportTypeDefinition { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
    }
}