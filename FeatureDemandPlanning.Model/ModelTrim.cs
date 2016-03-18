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

        public virtual string Identifier
        {
            get { return DPCK; }
        }

        public static ModelTrim FromIdentifier(string dpck)
        {
            return new ModelTrim()
            {
                DPCK = dpck
            };
        }
    }

    public class ImportTrim : ModelTrim
    {
        public override string Identifier
        {
            get { return Name; }
        }
    }
}