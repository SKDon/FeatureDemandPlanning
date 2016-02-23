namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ValidationRule
    {
        TakeRateOutOfRange = 1,
        VolumeForFeatureGreaterThanModel = 2,
        VolumeForModelsGreaterThanMarket = 3,
        TotalTakeRateForModelsOutOfRange = 4,
        StandardFeaturesShouldBe100Percent = 5,
        TakeRateForPackFeaturesShouldBeEquivalent = 6,
        TakeRateForEfgShouldEqualTo100Percent = 7,
        NonApplicableFeaturesShouldBe0Percent = 8,
        TakeRateForEfgShouldbeLessThanOrEqualTo100Percent = 9,
        OnlyOneFeatureInEfg = 10
    }
}
