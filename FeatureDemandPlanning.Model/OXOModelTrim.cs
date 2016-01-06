namespace FeatureDemandPlanning.Model
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