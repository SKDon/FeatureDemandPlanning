namespace FeatureDemandPlanning.Model.Empty
{
    public class EmptyFdpSpecialFeature : FdpSpecialFeature
    {
        public EmptyFdpSpecialFeature()
        {
            Type = new EmptySpecialFeatureType();
        }
    }
}
