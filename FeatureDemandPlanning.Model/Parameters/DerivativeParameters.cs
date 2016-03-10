using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class DerivativeParameters : JQueryDataTableParameters
    {
        public int? DerivativeId { get; set; }
        public string DerivativeCode { get; set; }

        public int? DocumentId { get; set; }
        public int? ProgrammeId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public string FilterMessage { get; set; }

        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }

        public DerivativeAction Action { get; set; }

        public DerivativeParameters()
        {
            Action = DerivativeAction.NotSet;
        }

        public virtual object GetActionSpecificParameters()
        {
            if (Action == DerivativeAction.Delete)
            {
                return new
                {
                    DerivativeId = DerivativeId
                };
            }

            return new { };
        }
    }
}
