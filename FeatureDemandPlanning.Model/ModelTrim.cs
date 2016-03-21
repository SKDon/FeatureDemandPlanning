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
            get
            {
                return !string.IsNullOrEmpty(DPCK)
                    ? string.Format("{0}|{1}", DPCK, Id)
                    : Id.ToString();
            }
        }

        public static ModelTrim FromIdentifier(string identifier)
        {
            var elements = identifier.Split('|');
            if (elements.Length == 2)
            {
                return new ModelTrim()
                {
                    DPCK = elements[0],
                    Id = int.Parse(elements[1])
                };
            }
            return new ModelTrim()
            {
                Id = int.Parse(elements[0])
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