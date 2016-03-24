using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model
{
    public class FdpSpecialFeature : FdpFeature
    {
        public int FdpSpecialFeatureTypeId { get; set; }
        public string SpecialFeatureType { get; set; }
        public FdpSpecialFeatureType Type { get; set; }

        public FdpSpecialFeature()
        {
            Type = new EmptySpecialFeatureType();
        }
    }
}
