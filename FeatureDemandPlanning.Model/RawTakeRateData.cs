﻿using System;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class RawTakeRateData
    {
        public IEnumerable<RawTakeRateDataItem> DataItems { get; set; }
        public IEnumerable<RawTakeRateSummaryItem> SummaryItems { get; set; }
        public IEnumerable<RawTakeRateFeatureMixItem> FeatureMixItems { get; set; }
        public IEnumerable<RawPowertrainDataItem> PowertrainDataItems { get; set; }
        public IEnumerable<RawFeaturePackItem> PackFeatures { get; set; } 
        public int TotalVolume { get; set; }

        public IEnumerable<EfgGrouping> EfgGroupings
        {
            get { return CalculateEfgGrouping(); }
        }

        public IEnumerable<FeaturePack> FeaturePacks
        {
            get { return CalculateFeaturePacks(); }
        }

        // This gets round a problem in FluentValidation with state and collections
        public IEnumerable<RawTakeRateDataItem> FeaturesWithVolumeGreaterThanModel
        {
            get { return ListFeaturesWithVolumeGreaterThanModel(); }
        }

        public RawTakeRateData()
        {
            DataItems = Enumerable.Empty<RawTakeRateDataItem>();
            SummaryItems = Enumerable.Empty<RawTakeRateSummaryItem>();
            FeatureMixItems = Enumerable.Empty<RawTakeRateFeatureMixItem>();
            PowertrainDataItems = Enumerable.Empty<RawPowertrainDataItem>();
            PackFeatures = Enumerable.Empty<RawFeaturePackItem>();
        }

        private IEnumerable<RawTakeRateDataItem> ListFeaturesWithVolumeGreaterThanModel()
        {
            var features = new List<RawTakeRateDataItem>();
            foreach (var dataItem in DataItems)
            {
                var modelVolume = dataItem.ModelId.HasValue
                    ? SummaryItems.First(m => m.ModelId == dataItem.ModelId).Volume
                    : SummaryItems.First(m => m.FdpModelId == dataItem.FdpModelId).Volume;

                if (dataItem.Volume > modelVolume)
                {
                    features.Add(dataItem);
                }
            }
            return features;
        }

        private static bool IsInExclusiveFeatureGroup(RawTakeRateDataItem dataItem)
        {
            try
            {
                return !string.IsNullOrEmpty(dataItem.ExclusiveFeatureGroup)
                       && !dataItem.OxoCode.Contains("NA")
                       && dataItem.ModelId.HasValue
                       && dataItem.FeaturesInExclusiveFeatureGroup > 1;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private static bool IsInFeaturePack(RawTakeRateDataItem dataItem)
        {
            try
            {
                return !dataItem.OxoCode.Contains("P") && dataItem.FeaturePackId.HasValue;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private IEnumerable<EfgGrouping> CalculateEfgGrouping()
        {
            if (!DataItems.Any())
                return Enumerable.Empty<EfgGrouping>();

            if (_grouping != null)
                return _grouping;

            var grouping =
                from dataItem in DataItems
                where IsInExclusiveFeatureGroup(dataItem)
                group dataItem by new
                {
                    TakeRateId = dataItem.FdpVolumeHeaderId,
                    dataItem.MarketId,
                    ModelId = dataItem.ModelId.GetValueOrDefault(),
                    dataItem.ExclusiveFeatureGroup
                }
                into g
                select new EfgGrouping
                {
                    TakeRateId = g.Key.TakeRateId,
                    MarketId = g.Key.MarketId,
                    Market = g.First().Market,
                    ModelId = g.Key.ModelId,
                    Model = g.First().Model,
                    ExclusiveFeatureGroup = g.Key.ExclusiveFeatureGroup,
                    TotalPercentageTakeRate = g.Sum(p => p.PercentageTakeRate),
                    HasStandardFeatureInGroup = g.Any(d => d.IsStandardFeatureInGroup),
                    NumberOfItemsWithTakeRate = g.Count(d => d.PercentageTakeRate > 0),
                    FeatureId = GetFirstFeatureIdentifierInGroup(g)
                };

            _grouping = grouping;

            return _grouping;
        }

        private static int? GetFirstFeatureIdentifierInGroup(IEnumerable<RawTakeRateDataItem> groupItems)
        {
            var standardFeature = groupItems.FirstOrDefault(d => d.IsStandardFeatureInGroup);

            if (standardFeature != null)
                return standardFeature.FeatureId;

            var optionalFeature = groupItems.OrderBy(d => d.FeatureCode).FirstOrDefault();
            if (optionalFeature != null)
            {
                return optionalFeature.FeatureId;
            }

            return null;
        }
        private IEnumerable<FeaturePack> CalculateFeaturePacks()
        {
            if (!DataItems.Any())
                return Enumerable.Empty<FeaturePack>();

            if (_packs != null)
                return _packs;

            var packs =
                (from packItem in PackFeatures
                group packItem by new
                {
                    TakeRateId = packItem.FdpVolumeHeaderId,
                    packItem.MarketId,
                    packItem.ModelId,
                    packItem.FeaturePackId,
                    PackName = packItem.FeaturePackName
                }
                into g
                select new FeaturePack
                {
                    TakeRateId = g.Key.TakeRateId,
                    MarketId = g.Key.MarketId,
                    ModelId = g.Key.ModelId,
                    FeaturePackId = g.Key.FeaturePackId,
                    PackName = g.Key.PackName,
                    PackItems = g.ToList()
                })
                .ToList();

            // Populate the actual take rate data for each pack
            // I changed the way packs and features were determined to cater for features in multiple packs, 
            // just didn't want to rewrite all the take rate routines
            foreach (var pack in packs)
            {
                var featuresInPack = pack.PackItems.Select(f => f.FeatureId).ToList();
                pack.DataItems = DataItems
                    .Where(d =>
                        d.MarketId == pack.MarketId &&
                        d.ModelId.GetValueOrDefault() == pack.ModelId &&
                        (
                            // Feature pack data item
                            featuresInPack.Contains(d.FeatureId.GetValueOrDefault())
                            ||
                            // Feature pack itself
                            (!d.FeatureId.HasValue && d.FeaturePackId.GetValueOrDefault() == pack.FeaturePackId)
                        )
                    )
                    .ToList();

                if (!pack.DataItems.Any()) continue;

                pack.Market = pack.DataItems.First().Market;
                pack.Model = pack.DataItems.First().Model;
            }

            _packs = packs;

            return _packs;
        }

        private IEnumerable<EfgGrouping> _grouping;
        private IEnumerable<FeaturePack> _packs;

        public int GetModelVolume(int? modelId)
        {
            var model = SummaryItems.FirstOrDefault(s => s.ModelId == modelId);
            return model != null ? model.Volume : 0;
        }

        public int GetFdpModelVolume(int? fdpModelId)
        {
            var model = SummaryItems.FirstOrDefault(s => s.FdpModelId == fdpModelId);
            return model != null ? model.Volume : 0;
        }

        public int GetMarketVolume()
        {
            var models = SummaryItems.Where(s => !s.ModelId.HasValue && !s.FdpModelId.HasValue);
            var rawTakeRateSummaryItems = models as IList<RawTakeRateSummaryItem> ?? models.ToList();
            return rawTakeRateSummaryItems.Any() ? rawTakeRateSummaryItems.Sum(s => s.Volume) : 0;
        }

        public int GetAllMarketVolume()
        {
            return TotalVolume;
        }
    }
}
