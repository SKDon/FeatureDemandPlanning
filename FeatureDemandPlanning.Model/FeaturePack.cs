using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class FeaturePack
    {
        public int TakeRateId { get; set; }
        public int MarketId { get; set; }
        public string Market { get; set; }
        public int ModelId { get; set; }
        public string Model { get; set; }
        public int FeaturePackId { get; set; }
        public string PackName { get; set; }

        public IEnumerable<RawTakeRateDataItem> PackItems { get; set; }

        public int PackVolume
        {
            get
            {
                var parentPack = PackItems.FirstOrDefault(d => !d.FeatureId.HasValue && d.FeaturePackId.HasValue);
                return parentPack == null ? 0 : parentPack.Volume;
            }
        }

        public decimal PackPercentageTakeRate
        {
            get
            {
                var parentPack = PackItems.FirstOrDefault(d => !d.FeatureId.HasValue && d.FeaturePackId.HasValue);
                return parentPack == null ? 0 : parentPack.PercentageTakeRate;
            }
        }

        public int DistinctTakeRates()
        {
            var takeRates = PackItems.Where(p => !p.IsStandardFeatureInGroup && !p.IsNonApplicableFeatureInGroup && !p.IsOptionalFeatureInGroup)
                .Select(p => p.PercentageTakeRate);
            
            return takeRates.Distinct().Count();
        }
        
        public bool HasMultipleTakeRates()
        {
            if (PackItems == null || !PackItems.Any())
                return false;

            var distinctTakeRates =  DistinctTakeRates();

            return distinctTakeRates > 1;
        }
    }
}
