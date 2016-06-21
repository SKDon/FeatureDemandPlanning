using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class FeaturePackExtensions
    {
        public static bool IsFeatureTakeRateEquivalentToPack(this IEnumerable<FeaturePack> featurePacks, FeaturePack forPack)
        {
            // Iterate through the pack features and obtain the take rate of the feature
            // The take rate of the features must be the aggregate of all packs containing the feature

            foreach (var packItem in forPack.DataItems)
            {
                // Skip standard features, non-applicable features and optional features that may be chosen outside the pack
                if (packItem.IsStandardFeatureInGroup || packItem.IsOptionalFeatureInGroup ||
                    packItem.IsNonApplicableFeatureInGroup || packItem.IsUncodedFeature)
                {
                    continue;
                }

                // Skip pack items that are in exclusive feature groups, as these will be picked up by other rules
                // If the item is in an exclusive feature group by itself (1 item in group), then we need to validate
                // Also if this item is a pack-only item, we need to validate, otherwise no other rules will pick this up

                if (!string.IsNullOrEmpty(packItem.ExclusiveFeatureGroup) && 
                    packItem.FeaturesInExclusiveFeatureGroup > 1 && 
                    !packItem.IsPackOnlyItem)
                {
                    continue;
                }

                // Get the combined take rate of all packs that contain the feature

                var combinedPackTakeRate =
                    featurePacks.Where(p => p.ModelId == forPack.ModelId &&
                        p.DataItems.Any(d => d.FeatureId == packItem.FeatureId.GetValueOrDefault()))
                    .Sum(p => p.PackPercentageTakeRate);

                if (packItem.PercentageTakeRate != combinedPackTakeRate)
                {
                    return false;
                }
            }
            return true;
        }

        public static bool IsFeaturePlusPackTakeLessThan100Percent(this IEnumerable<FeaturePack> featurePacks, FeaturePack forPack)
        {
            // Iterate through the pack features and obtain the take rate of the feature
            // The take rate of the features must be the aggregate of all packs containing the feature

            foreach (var packItem in forPack.DataItems)
            {
                // Skip everything except optional features
                if (!packItem.IsOptionalFeatureInGroup)
                {
                    continue;
                }

                // Get the combined take rate of all packs that contain the feature

                var combinedPackTakeRate =
                    featurePacks.Where(p => p.ModelId == forPack.ModelId &&
                        p.DataItems.Any(d => d.FeatureId == packItem.FeatureId.GetValueOrDefault()))
                    .Sum(p => p.PackPercentageTakeRate);

                if (packItem.PercentageTakeRate + combinedPackTakeRate > 1)
                {
                    return false;
                }
            }
            return true;
        }
    }
}
