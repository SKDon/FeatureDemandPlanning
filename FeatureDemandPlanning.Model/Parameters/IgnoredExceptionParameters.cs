using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class IgnoredExceptionParameters : JQueryDataTableParameters
    {
        public int? IgnoredExceptionId { get; set; }
        public string IgnoredExceptionCode { get; set; }

        public int? ProgrammeId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public string FilterMessage { get; set; }

        public IgnoredExceptionAction Action { get; set; }

        public IgnoredExceptionParameters()
        {
            Action = IgnoredExceptionAction.NotSet;
        }

        public virtual object GetActionSpecificParameters()
        {
            if (Action == IgnoredExceptionAction.Delete)
            {
                return new
                {
                    IgnoredExceptionId = IgnoredExceptionId
                };
            }

            return new { };
        }
    }
}
