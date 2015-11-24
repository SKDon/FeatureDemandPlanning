using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class DerivativeFilter : FilterBase
    {
        public int? DerivativeId { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public int? EngineId { get; set; }
        public int? BodyId { get; set; }
        public int? TransmissionId { get; set; }

        public bool IncludeAllDerivatives { get; set; }

        public DerivativeAction Action { get; set; }

        public DerivativeFilter()
        {
            Action = DerivativeAction.NotSet;
        }

        public static DerivativeFilter FromDerivativeId(int? derivativeId)
        {
            return new DerivativeFilter()
            {
                DerivativeId = derivativeId
            };
        }
        public static DerivativeFilter FromParameters(DerivativeParameters parameters)
        {
            return new DerivativeFilter()
            {
                DerivativeId = parameters.DerivativeId,
                Action = parameters.Action
            };
        }
    }
}
