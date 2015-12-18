using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class DataChange
    {
        public int? FdpChangesetId { get; set; }
        public int? FdpChangesetDataItemId { get; set; }

        public int? MarketId { get; set; }
        public string ModelIdentifier { get; set; }
        public string FeatureIdentifier { get; set; }
        public string Comment { get; set; }
        public int? Volume { get; set; }
        public decimal? PercentageTakeRate { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public string Note { get; set; }

        public string DataTarget
        {
            get
            {
                var dataTarget = string.Empty;
                if (IsWholeMarketChange())
                {
                    dataTarget = MarketId.ToString();
                }
                else if (IsModelSummary)
                {
                    dataTarget = string.Format("{0}|{1}", MarketId, ModelIdentifier);
                }
                else if (IsFeatureSummary)
                {
                    dataTarget = string.Format("{0}|{1}", MarketId, FeatureIdentifier);
                }
                else
                {
                    dataTarget = string.Format("{0}|{1}|{2}", MarketId, ModelIdentifier, FeatureIdentifier);
                }
                return dataTarget;
            }
        }

        public int? GetModelId()
        {
            if (string.IsNullOrEmpty(ModelIdentifier))
                return null;

            return int.Parse(ModelIdentifier.Substring(1));
        }
        public int? GetFeatureId()
        {
            if (string.IsNullOrEmpty(FeatureIdentifier))
                return null;

            return int.Parse(FeatureIdentifier.Substring(1));
        }
        public bool IsModelSummary
        {
            get
            {
                return !string.IsNullOrEmpty(ModelIdentifier) && string.IsNullOrEmpty(FeatureIdentifier);
            }
        }
        public bool IsFeatureSummary
        {
            get
            {
                return string.IsNullOrEmpty(ModelIdentifier) && !string.IsNullOrEmpty(FeatureIdentifier);
            }
        }
        public bool IsFdpModel
        {
            get
            {
                return !string.IsNullOrEmpty(ModelIdentifier) && ModelIdentifier.StartsWith("F");
            }
        }
        public bool IsFdpFeature
        {
            get
            {
                return !string.IsNullOrEmpty(FeatureIdentifier) && FeatureIdentifier.StartsWith("F");
            }
        }
        public TakeRateDataItem ToDataItem()
        {
            var dataItem = new TakeRateDataItem()
            {
                Volume = Volume.GetValueOrDefault(),
                PercentageTakeRate = PercentageTakeRate.GetValueOrDefault(),
                ModelId = !IsFdpModel ? GetModelId() : null,
                FdpModelId = IsFdpModel ? GetModelId() : null,
                FeatureId = !IsFdpFeature ? GetFeatureId() : null,
                FdpFeatureId = IsFdpFeature ? GetFeatureId() : null,
                MarketId = MarketId
            };
            if (!string.IsNullOrEmpty(Note)) {
                dataItem.Notes = new List<TakeRateDataItemNote>() { new TakeRateDataItemNote(Note) };
            }
            return dataItem;
        }
        public bool IsWholeMarketChange()
        {
            return MarketId.HasValue && 
                string.IsNullOrEmpty(ModelIdentifier) && 
                string.IsNullOrEmpty(FeatureIdentifier);
        }

        public decimal? PercentageTakeRateAsFraction
        {
            get
            {
                if (!PercentageTakeRate.HasValue)
                    return null;

                return PercentageTakeRate / 100;
            }
        }
    }
}
