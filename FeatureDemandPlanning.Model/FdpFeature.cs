using System;
using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class FdpFeature : Feature
    {
        public int? FeatureId { get; set; }
        public int? FeaturePackId { get; set; }
        public int? DocumentId { get; set; }
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

        public virtual string Identifier
        {
            get
            {
                if (!FeatureId.HasValue && FeaturePackId.HasValue)
                {
                    return !string.IsNullOrEmpty(FeatureCode)
                    ? string.Format("{0}|P{1}", FeatureCode, FeaturePackId)
                    : FeaturePackId.ToString();
                }
                return !string.IsNullOrEmpty(FeatureCode)
                    ? string.Format("{0}|O{1}", FeatureCode, FeatureId)
                    : FeatureId.ToString();
            }
        }

        public static FdpFeature FromIdentifier(string identifier)
        {
            var elements = identifier.Split('|');
            var feature = new FdpFeature();
            if (elements.Length == 2)
            {
                feature.FeatureCode = elements[0];
                if (elements[1].StartsWith("P"))
                {
                    feature.FeaturePackId = int.Parse(elements[1].Substring(1));
                }
                else
                {
                    feature.FeatureId = int.Parse(elements[1].Substring(1));
                }
            }
            else
            {
                if (elements[0].StartsWith("P"))
                {
                    feature.FeaturePackId = int.Parse(elements[0].Substring(1));
                }
                else
                {
                    feature.FeatureId = int.Parse(elements[0].Substring(1));
                }
            }
            return feature;
        }

        public static FdpFeature FromParameters(Parameters.FeatureParameters parameters)
        {
            throw new NotImplementedException();
        }
    }
}
