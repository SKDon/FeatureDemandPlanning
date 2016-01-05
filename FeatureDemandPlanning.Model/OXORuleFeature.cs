namespace FeatureDemandPlanning.Model
{
    public class RuleFeature : BusinessObject
    {
            public int RuleId { get; set; }
            public int ProgrammeId { get; set; }
            public int FeatureId { get; set; }

           
        // A blank constructor
        public RuleFeature() {;}
    }
}