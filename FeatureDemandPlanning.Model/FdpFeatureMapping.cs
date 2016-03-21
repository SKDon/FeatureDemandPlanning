using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpFeatureMapping : FdpFeature
    {
        public int? FdpFeatureMappingId { get; set; }
        public string ImportFeatureCode { get; set; }
        public bool? IsMappedFeature { get; set; }

        public new virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpFeatureMappingId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ImportFeatureCode,
                FeatureCode,
                Description
            };
        }
        public static FdpFeatureMapping FromParameters(FeatureMappingParameters parameters)
        {
            return new FdpFeatureMapping()
            {
                FdpFeatureMappingId = parameters.FeatureMappingId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }

    public class OxoFeature : FdpFeatureMapping
    {
        public OXODoc Document { get; set; }

        public OxoFeature()
        {
            
        }
        public OxoFeature(FdpFeature fromFeature)
        {
            DocumentId = fromFeature.DocumentId;
            ProgrammeId = fromFeature.ProgrammeId;
            Gateway = fromFeature.Gateway;
            CreatedOn = fromFeature.CreatedOn;
            CreatedBy = fromFeature.CreatedBy;
            UpdatedOn = fromFeature.UpdatedOn;
            UpdatedBy = fromFeature.UpdatedBy;
            IsActive = fromFeature.IsActive;
            Description = fromFeature.Description;
            FeatureCode = fromFeature.FeatureCode;
            FeatureId = fromFeature.FeatureId;
            FeaturePackId = fromFeature.FeaturePackId;
        }

        public override string[] ToJQueryDataTableResult()
        {
            if (FeaturePackId.HasValue && !FeatureId.HasValue)
            {
                return new[]
                {
                    string.Format("{0}|P{1}", DocumentId, FeaturePackId),
                    Programme.GetDisplayString(),
                    Gateway,
                    Document.Name,
                    FeatureCode,
                    Description
                };
            }
            return new[]
            {
                string.Format("{0}|F{1}", DocumentId, FeatureId),
                Programme.GetDisplayString(),
                Gateway,
                Document.Name,
                FeatureCode,
                Description
            };
        }

        public new static OxoFeature FromParameters(FeatureMappingParameters parameters)
        {
            return new OxoFeature
            {
                FeatureId = parameters.FeatureId,
                FeaturePackId = parameters.FeaturePackId,
                DocumentId = parameters.DocumentId,
                FeatureCode = parameters.FeatureCode
            };
        }
    }
}
