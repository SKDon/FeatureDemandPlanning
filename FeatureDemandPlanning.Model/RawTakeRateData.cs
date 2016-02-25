using System;
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
                    NumberOfItemsWithTakeRate = g.Count(d => d.PercentageTakeRate > 0)
                };

            _grouping = grouping;

            return _grouping;
        }

        private IEnumerable<FeaturePack> CalculateFeaturePacks()
        {
            if (!DataItems.Any())
                return Enumerable.Empty<FeaturePack>();

            if (_packs != null)
                return _packs;

            var packs =
                from dataItem in DataItems
                where IsInFeaturePack(dataItem)
                group dataItem by new
                {
                    TakeRateId = dataItem.FdpVolumeHeaderId,
                    dataItem.MarketId,
                    ModelId = dataItem.ModelId.GetValueOrDefault(),
                    dataItem.FeaturePackId,
                    dataItem.PackName
                }
                into g
                select new FeaturePack
                {
                    TakeRateId = g.Key.TakeRateId,
                    MarketId = g.Key.MarketId,
                    Market = g.First().Market,
                    ModelId = g.Key.ModelId,
                    Model = g.First().Model,
                    FeaturePackId = g.Key.FeaturePackId.GetValueOrDefault(),
                    PackName = g.Key.PackName,
                    PackItems = g.ToList()
                };

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
