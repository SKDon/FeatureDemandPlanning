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
        public string BMC { get; set; }
           
        // A blank constructor
        public ModelTrim() {;}

        public virtual string Identifier
        {
            get
            {
                return !string.IsNullOrEmpty(DPCK) && !string.IsNullOrEmpty(BMC)
                    ? string.Format("{0}|{1}|{2}", BMC, DPCK, Id)
                    : Id.ToString();
            }
        }

        public static ModelTrim FromIdentifier(string identifier)
        {
            var elements = identifier.Split('|');
            if (elements.Length == 3)
            {
                return new ModelTrim()
                {
                    BMC = elements[0],
                    DPCK = elements[1],
                    Id = int.Parse(elements[2])
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