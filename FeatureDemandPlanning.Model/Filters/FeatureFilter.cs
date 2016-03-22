using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class FeatureFilter : FilterBase
    {
        public int? FeatureId { get; set; }

        public int? DocumentId { get; set; }
        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public string FeatureCode { get; set; }
        public string FilterMessage { get; set; }

        public FeatureAction Action { get; set; }

        public FeatureFilter()
        {
            Action = FeatureAction.NotSet;
        }

        public static FeatureFilter FromFeatureId(int? featureId)
        {
            return new FeatureFilter()
            {
                FeatureId = featureId
            };
        }
        public static FeatureFilter FromOxoDocumentId(int documentId)
        {
            return new FeatureFilter()
            {
                DocumentId = documentId
            };
        }
        public static FeatureFilter FromParameters(FeatureParameters parameters)
        {
            return new FeatureFilter()
            {
                FeatureId = parameters.FeatureId,
                Action = parameters.Action
            };
        }

        public bool IncludeAllFeatures { get; set; }
        public bool OxoFeaturesOnly { get; set; }
    }
}
