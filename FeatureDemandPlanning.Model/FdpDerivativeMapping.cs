using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpDerivativeMapping : FdpDerivative
    {
        public int? FdpDerivativeMappingId { get; set; }
        public string ImportDerivativeCode { get; set; }

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

    public class OxoDerivative : FdpDerivativeMapping
    {
        public OXODoc Document { get; set; }

        public OxoDerivative()
        {
            
        }

        public OxoDerivative(FdpDerivative fromDerivative)
        {
            DocumentId = fromDerivative.DocumentId;
            ProgrammeId = fromDerivative.ProgrammeId;
            Gateway = fromDerivative.Gateway;
            CreatedOn = fromDerivative.CreatedOn;
            CreatedBy = fromDerivative.CreatedBy;
            UpdatedOn = fromDerivative.UpdatedOn;
            UpdatedBy = fromDerivative.UpdatedBy;
            IsActive = fromDerivative.IsActive;
            BodyId = fromDerivative.BodyId;
            EngineId = fromDerivative.EngineId;
            TransmissionId = fromDerivative.TransmissionId;
            DerivativeCode = fromDerivative.DerivativeCode;
        }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                string.Format("{0}|{1}|{2}|{3}", DocumentId, BodyId, EngineId, TransmissionId),
                Programme.GetDisplayString(),
                Gateway,
                Document.Name,
                DerivativeCode,
                Body.Name,
                Engine.Name,
                Transmission.Name
            };
        }

        public new static OxoDerivative FromParameters(DerivativeMappingParameters parameters)
        {
            return new OxoDerivative()
            {
                BodyId = parameters.BodyId,
                EngineId = parameters.EngineId,
                TransmissionId = parameters.TransmissionId,
                DocumentId = parameters.DocumentId,
                DerivativeCode = parameters.DerivativeCode
            };
        }
    }
}
