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

    public class OxoTrim : FdpTrimMapping
    {
        public OXODoc Document { get; set; }

        public OxoTrim()
        {

        }

        public OxoTrim(FdpTrim fromTrim)
        {
            DocumentId = fromTrim.DocumentId;
            ProgrammeId = fromTrim.ProgrammeId;
            Gateway = fromTrim.Gateway;
            CreatedOn = fromTrim.CreatedOn;
            CreatedBy = fromTrim.CreatedBy;
            UpdatedOn = fromTrim.UpdatedOn;
            UpdatedBy = fromTrim.UpdatedBy;
            IsActive = fromTrim.IsActive;
            DPCK = fromTrim.DPCK;
            Name = fromTrim.Name;
            Level = fromTrim.Level;
            Abbreviation = fromTrim.Abbreviation;
            TrimId = fromTrim.TrimId;
        }

        public new string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                string.Format("{0}|{1}", DocumentId, TrimId),
                Programme.GetDisplayString(),
                Gateway,
                Document.Name,
                DPCK,
                Name,
                Level
            };
        }

        public new static OxoTrim FromParameters(TrimMappingParameters parameters)
        {
            return new OxoTrim()
            {
                TrimId = parameters.TrimId,
                DocumentId = parameters.DocumentId,
                DPCK = parameters.Dpck
            };
        }
    }
}
