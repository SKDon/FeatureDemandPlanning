using System.Collections.Generic;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class DataChange
    {
        public int? FdpChangesetId { get; set; }
        public int? FdpChangesetDataItemId { get; set; }
        public int? ParentFdpChangesetDataItemId { get; set; }

        public int? MarketId { get; set; }
        public string ModelIdentifier { get; set; }
        public string FeatureIdentifier { get; set; }
        public string Comment { get; set; }
        public int? Volume { get; set; }
        public decimal? PercentageTakeRate { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public string Note { get; set; }

        // Only way of identifying powertrain changes

        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }

        public int? OriginalVolume { get; set; }
        public decimal OriginalPercentageTakeRate { get; set; }

        public bool IsMarketReview { get; set; }

        public DataChange()
        {
            
        }
        public DataChange(DataChange parentChange)
        {
            MarketId = parentChange.MarketId;
            ModelIdentifier = parentChange.ModelIdentifier;
            FeatureIdentifier = parentChange.FeatureIdentifier;
            Comment = parentChange.Comment;
        }

        public string DataTarget
        {
            get
            {
                string dataTarget;
                if (IsWholeMarketChange)
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

        public bool IsFeature
        {
            get
            {
                return !string.IsNullOrEmpty(FeatureIdentifier) && FeatureIdentifier.StartsWith("O");
            }
        }
        public bool IsFdpFeature
        {
            get
            {
                return !string.IsNullOrEmpty(FeatureIdentifier) && FeatureIdentifier.StartsWith("F");
            }
        }
        public bool IsFeaturePack
        {
            get
            {
                return !string.IsNullOrEmpty(FeatureIdentifier) && FeatureIdentifier.StartsWith("P");
            }
        }
        public bool IsWholeMarketChange
        {
            get
            {
                return MarketId.HasValue &&
                       string.IsNullOrEmpty(ModelIdentifier) &&
                       string.IsNullOrEmpty(FeatureIdentifier) &&
                       !IsPowertrainChange;
            }
        }
        public bool IsPowertrainChange
        {
            get { return BodyId.HasValue && EngineId.HasValue && TransmissionId.HasValue; }
        }
        public TakeRateDataItem ToDataItem()
        {
            if (IsPowertrainChange)
            {
                return new EmptyTakeRateDataItem();
            }
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

        public decimal? PercentageTakeRateAsFraction
        {
            get
            {
                return PercentageTakeRate / 100;
            }
        }

        public bool IsFeatureChange
        {
            get
            {
                return !IsModelSummary && !IsFeatureSummary && !IsWholeMarketChange;
            }
        }

        public int? FdpVolumeDataItemId { get; set; }
        public int? FdpTakeRateSummaryId { get; set; }
        public int? FdpTakeRateFeatureMixId { get; set; }
        public int? FdpPowertrainDataItemId { get; set; }
    }
}
