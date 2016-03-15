using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TrimParameters : JQueryDataTableParameters
    {
        public int? TrimId { get; set; }
        public string Trim { get; set; }
        public string Level { get; set; }

        public int? ProgrammeId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public string FilterMessage { get; set; }
        public string DerivativeCode { get; set; }

        public TrimAction Action { get; set; }

        public TrimParameters()
        {
            Action = TrimAction.NotSet;
        }

        public virtual object GetActionSpecificParameters()
        {
            if (Action == TrimAction.Delete)
            {
                return new
                {
                    TrimId
                };
            }

            return new { };
        }
    }
}
