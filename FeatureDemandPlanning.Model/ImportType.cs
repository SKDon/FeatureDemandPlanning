using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class ImportType
    {
        public enums.ImportType ImportTypeDefinition { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
    }
}