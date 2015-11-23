using System;
using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class FdpFeature : Feature
    {
        public int? FeatureId { get; set; }
        public int? ProgrammeId { get; set; }
        public Programme Programme { get; set; }
        public string Gateway { get; set; }
        public string Description { get; set; }

        public int? FdpFeatureId { get; set; }
        public int? FeatureGroupId { get; set; }
        public bool IsActive { get; set; }

        public DateTime? UpdatedOn { get; set; }

        public FdpFeature()
        {
            IsActive = true;
            Programme = new EmptyProgramme();
        }
        public virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpFeatureId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                FeatureCode,
                Description
            };
        }

        public static FdpFeature FromParameters(Parameters.FeatureParameters parameters)
        {
            throw new NotImplementedException();
        }
    }
}
