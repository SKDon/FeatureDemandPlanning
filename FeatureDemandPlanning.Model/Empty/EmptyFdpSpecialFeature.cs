namespace FeatureDemandPlanning.Model.Empty
{
    public class EmptyFdpSpecialFeature : FdpSpecialFeature
    {
        public EmptyFdpSpecialFeature()
        {
            SpecialFeatureType = new EmptySpecialFeatureType();
        }
    }
}
