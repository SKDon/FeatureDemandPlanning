using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class TrimFilter : FilterBase
    {
        public int? TrimId { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public string Name { get; set; }
        public string Level { get; set; }

        public TrimAction Action { get; set; }

        public bool IncludeAllTrim { get; set; }
        public bool OxoTrimOnly { get; set; }
        public string DerivativeCode { get; set; }

        public TrimFilter()
        {
            Action = TrimAction.NotSet;
            IncludeAllTrim = false;
        }
        public static TrimFilter FromTrimId(int? trimId)
        {
            return new TrimFilter
            {
                TrimId = trimId
            };
        }
        public static TrimFilter FromParameters(TrimParameters parameters)
        {
            return new TrimFilter
            {
                TrimId = parameters.TrimId,
                Action = parameters.Action
            };
        }
    }
}
