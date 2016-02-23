using System.Collections.Generic;
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

        public bool HasMultipleTakeRates()
        {
            if (PackItems == null || !PackItems.Any())
                return false;

            return PackItems.Select(p => p.PercentageTakeRate).Distinct().Count() > 1;
        }
    }
}
