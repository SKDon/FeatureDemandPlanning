using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class FdpTrim : ModelTrim
    {
        public int? TrimId { get; set; }
        public int? FdpTrimId { get; set; }
        //public new int? ProgrammeId { get; set; }
        public Programme Programme { get; set; }
        public string Gateway { get; set; }
        public string BMC { get; set; }

        public bool IsFdpTrim { get; set; }

        public virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpTrimId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                BMC,
                Name,
                Level
            };
        }

        public static FdpTrim FromParameters(Parameters.TrimParameters parameters)
        {
            return new FdpTrim()
            {
                FdpTrimId = parameters.TrimId,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway
            };
        }
    }
}
