using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class FeatureParameters : JQueryDataTableParameters
    {
        public int? FeatureId { get; set; }
        public int? FeaturePackId { get; set; }
        public string FeatureCode { get; set; }

        public int? ProgrammeId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public string FilterMessage { get; set; }

        public FeatureAction Action { get; set; }

        public FeatureParameters()
        {
            Action = FeatureAction.NotSet;
        }

        public virtual object GetActionSpecificParameters()
        {
            if (Action == FeatureAction.Delete)
            {
                return new
                {
                    FeatureId
                };
            }

            return new { };
        }
    }
}
