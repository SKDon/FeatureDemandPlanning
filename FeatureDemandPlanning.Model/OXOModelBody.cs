namespace FeatureDemandPlanning.Model
{
    public class ModelBody : BusinessObject
    {
        public string TypeName { get { return "ModelBody"; } }
        public int ProgrammeId { get; set; }
        public string Shape { get; set; }
        public string Doors { get; set; }
        public string Wheelbase { get; set; }       
        public string Name
        {
            get { return string.Format("{0} {1} {2}", Shape, Doors, (Wheelbase == "SWB" ? "" : Wheelbase)); }
        }
        
        // A blank constructor
        public ModelBody() {;}
    }
}