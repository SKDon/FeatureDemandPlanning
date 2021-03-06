﻿namespace FeatureDemandPlanning.Model
{
    // POCO representing raw(ish) take rate information to use for validation
    // Includes metadata such as feature / model name to better describe any validation failures
    public class RawTakeRateFeatureMixItem
    {
        public int FdpVolumeHeaderId { get; set; }
        public int FdpTakeRateFeatureMixId { get; set; }
        public int? FdpChangesetDataItemId { get; set; }
        public int MarketId { get; set; }
        public string Market { get; set; }
        public int MarketGroupId { get; set; }
        public string MarketGroup { get; set; }
        public int? FeatureId { get; set; }
        public int? FdpFeatureId { get; set; }
        public int? FeaturePackId { get; set; }
        public string FeatureCode { get; set; }
        public string FeatureDescription { get; set; }
        public string ExclusiveFeatureGroup { get; set; }
        public string Model { get; set; }
        public string OxoCode { get; set; }
        public bool IsStandardFeatureInGroup { get; set; }
        public bool IsOptionalFeatureInGroup { get; set; }
        public bool IsNonApplicableFeatureInGroup { get; set; }
        public int FeaturesInExclusiveFeatureGroup { get; set; }
        public int ApplicableFeaturesInExclusiveFeatureGroup { get; set; }
        public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }

        public string FeatureIdentifier
        {
            get
            {
                if (FeatureId.HasValue)
                {
                    return "O" + FeatureId;
                }
                if (FdpFeatureId.HasValue)
                {
                    return "F" + FdpFeatureId;
                }
                if (!FeatureId.HasValue && FeaturePackId.HasValue)
                {
                    return "P" + FeaturePackId;
                }
                return string.Empty;
            }
        }
    }
}

