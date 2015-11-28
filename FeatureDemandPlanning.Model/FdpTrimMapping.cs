using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpTrimMapping : FdpTrim
    {
        public int? FdpTrimMappingId { get; set; }
        public string ImportTrim { get; set; }
        public bool? IsMappedTrim { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpTrimMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                BMC,
                ImportTrim,
                Name,
                Level,
                DPCK
            };
        }
        public static FdpTrimMapping FromParameters(TrimMappingParameters parameters)
        {
            return new FdpTrimMapping()
            {
                FdpTrimMappingId = parameters.TrimMappingId,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway
            };
        }

        public string GetIdentifierString()
        {
            if (FdpTrimId.HasValue)
            {
                return string.Format("F{0}", FdpTrimId);
            }
            else
            {
                return string.Format("O{0}", TrimId);
            }
        }
    }
}
