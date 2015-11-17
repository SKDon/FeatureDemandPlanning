using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class MarketParameters : JQueryDataTableParameters
    {
        public int? MarketId { get; set; }
        public string Market { get; set; }

        public int? ProgrammeId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public string FilterMessage { get; set; }

        public MarketAction Action { get; set; }

        public MarketParameters()
        {
            Action = MarketAction.NotSet;
        }

        public virtual object GetActionSpecificParameters()
        {
            if (Action == MarketAction.Delete)
            {
                return new
                {
                    MarketId = MarketId
                };
            }

            return new { };
        }
    }
}
