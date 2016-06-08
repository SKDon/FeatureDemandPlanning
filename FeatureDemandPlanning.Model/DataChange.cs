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

        public string DerivativeCode { get; set; }
        public int? FdpOxoDerivativeId { get; set; }
        public int? FdpDerivativeId { get; set; }

        public int? OriginalVolume { get; set; }
        public decimal OriginalPercentageTakeRate { get; set; }

        public bool IsMarketReview { get; set; }
        public bool IsReverted { get; set; }

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
                else if (IsPowertrainChange)
                {
                    dataTarget = string.Format("{0}|{1}", MarketId, DerivativeCode);
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
                return !string.IsNullOrEmpty(ModelIdentifier) && string.IsNullOrEmpty(FeatureIdentifier) && !IsNote;
            }
        }
        public bool IsFeatureSummary
        {
            get
            {
                return string.IsNullOrEmpty(ModelIdentifier) && !string.IsNullOrEmpty(FeatureIdentifier) && !IsNote;
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
                       !IsPowertrainChange && !IsNote;
            }
        }

        public bool IsAllMarketChange
        {
            get
            {
                return !MarketId.HasValue &&
                       string.IsNullOrEmpty(ModelIdentifier) &&
                       string.IsNullOrEmpty(FeatureIdentifier) &&
                       !IsPowertrainChange && !IsNote;
            }
        }
        public bool IsPowertrainChange
        {
            get { return !string.IsNullOrEmpty(DerivativeCode) && !IsNote; }
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
                return !IsModelSummary && !IsFeatureSummary && !IsWholeMarketChange && !IsPowertrainChange && !IsNote;
            }
        }

        public bool IsNote
        {
            get { return !string.IsNullOrEmpty(Note); }
        }

        public int? FdpVolumeDataItemId { get; set; }
        public int? FdpTakeRateSummaryId { get; set; }
        public int? FdpTakeRateFeatureMixId { get; set; }
        public int? FdpPowertrainDataItemId { get; set; }

        public bool IsMatchingModel(RawTakeRateDataItem dataItem)
        {
            return (IsFdpModel && dataItem.FdpModelId == GetModelId()) || (!IsFdpModel && dataItem.ModelId == GetModelId());
        }

        public bool IsMatchingModel(RawTakeRateSummaryItem summaryItem)
        {
            return (IsFdpModel && summaryItem.FdpModelId == GetModelId()) || (!IsFdpModel && summaryItem.ModelId == GetModelId());
        }

        public bool IsMatchingFeature(RawTakeRateDataItem dataItem)
        {
            return (IsFdpFeature && dataItem.FdpFeatureId == GetFeatureId()) || (IsFeature && dataItem.FeatureId == GetFeatureId()) || (IsFeaturePack && !dataItem.FeatureId.HasValue && dataItem.FeaturePackId == GetFeatureId());
        }

        public bool IsMatchingFeatureMix(RawTakeRateFeatureMixItem mixItem)
        {
            return (IsFdpFeature && mixItem.FdpFeatureId == GetFeatureId()) || (IsFeature && mixItem.FeatureId == GetFeatureId()) || (IsFeaturePack && !mixItem.FeatureId.HasValue && mixItem.FeaturePackId == GetFeatureId());
        }

        public bool HasChanged
        {
            get
            {
                return ((Mode == TakeRateResultMode.PercentageTakeRate &&
                         OriginalPercentageTakeRate != PercentageTakeRateAsFraction.GetValueOrDefault()) ||
                        Mode == TakeRateResultMode.Raw && OriginalVolume != Volume.GetValueOrDefault());
            }
        }
    }
}
