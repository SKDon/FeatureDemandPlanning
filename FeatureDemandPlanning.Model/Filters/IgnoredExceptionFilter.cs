using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class IgnoredExceptionFilter : FilterBase
    {
        public int? IgnoredExceptionId { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public IgnoredExceptionAction Action { get; set; }

        public IgnoredExceptionFilter()
        {
            Action = IgnoredExceptionAction.NotSet;
        }

        public static IgnoredExceptionFilter FromIgnoredExceptionId(int? ignoredExceptionId)
        {
            return new IgnoredExceptionFilter()
            {
                IgnoredExceptionId = ignoredExceptionId
            };
        }
        public static IgnoredExceptionFilter FromParameters(IgnoredExceptionParameters parameters)
        {
            return new IgnoredExceptionFilter()
            {
                IgnoredExceptionId = parameters.IgnoredExceptionId,
                Action = parameters.Action
            };
        }
    }
}
