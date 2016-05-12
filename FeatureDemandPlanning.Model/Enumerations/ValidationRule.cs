using System;
using System.ComponentModel;

namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ValidationRule
    {
        [Description("Take rate out of range")]
        TakeRateOutOfRange = 1,
        [Description("Volume for feature greater than model")]
        VolumeForFeatureGreaterThanModel = 2,
        [Description("Volume for model greater than market")]
        VolumeForModelsGreaterThanMarket = 3,
        [Description("Total take rate for models out of range")]
        TotalTakeRateForModelsOutOfRange = 4,
        [Description("Standard features should be 100% take")]
        StandardFeaturesShouldBe100Percent = 5,
        [Description("Take rate for pack features should be equivalent")]
        TakeRateForPackFeaturesShouldBeEquivalent = 6,
        [Description("Total take rate for exclusive feature group should equal 100%")]
        TakeRateForEfgShouldEqualTo100Percent = 7,
        [Description("Non applicable features should be 0% take")]
        NonApplicableFeaturesShouldBe0Percent = 8,
        [Description("Take rate for exclusive feature group should be less than or equal to 100%")]
        TakeRateForEfgShouldbeLessThanOrEqualTo100Percent = 9,
        [Description("Only one feature in exclusive feature group can have a take rate")]
        OnlyOneFeatureInEfg = 10,
        [Description("Non coded feature cannot have a take rate")]
        NonCodedFeatureHasTakeRate = 11,
        [Description("Take rate for optional pack features should be greater than or equal to pack take rate")]
        OptionalPackFeaturesGreaterThanOrEqualToPack = 12
    }
}
