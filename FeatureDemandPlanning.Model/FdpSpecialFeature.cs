using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model
{
    public class FdpSpecialFeature : FdpFeature
    {
        public int FdpSpecialFeatureTypeId { get; set; }
        public FdpSpecialFeatureType SpecialFeatureType { get; set; }

        public FdpSpecialFeature()
        {
            SpecialFeatureType = new EmptySpecialFeatureType();
        }
    }
}
