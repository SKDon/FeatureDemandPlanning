using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpDerivativeMapping : FdpDerivative
    {
        public int? FdpDerivativeMappingId { get; set; }
        public string ImportDerivativeCode { get; set; }
        public bool? IsMappedDerivative { get; set; }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpDerivativeMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportDerivativeCode,
                DerivativeCode,
                Body.Name,
                Engine.Name,
                Transmission.Name
            };
        }
        public static FdpDerivativeMapping FromParameters(DerivativeMappingParameters parameters)
        {
            return new FdpDerivativeMapping()
            {
                FdpDerivativeMappingId = parameters.DerivativeMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
