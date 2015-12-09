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
        public string ModelIdentifier { get; set; }
        public string FeatureIdentifier { get; set; }
        public string Comment { get; set; }
        public int? Volume { get; set; }
        public decimal? PercentageTakeRate { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public string Note { get; set; }

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
        public bool IsFdpModel()
        {
            return ModelIdentifier.StartsWith("F");
        }
        public bool IsFdpFeature()
        {
            return FeatureIdentifier.StartsWith("F");
        }
        public TakeRateDataItem ToDataItem()
        {
            var dataItem = new TakeRateDataItem()
            {
                Volume = Volume.GetValueOrDefault(),
                PercentageTakeRate = PercentageTakeRate.GetValueOrDefault(),
                ModelId = !IsFdpModel() ? GetModelId() : null,
                FdpModelId = IsFdpModel() ? GetModelId() : null,
                FeatureId = !IsFdpFeature() ? GetFeatureId() : null,
                FdpFeatureId = IsFdpFeature() ? GetFeatureId() : null
            };
            if (!string.IsNullOrEmpty(Note)) {
                dataItem.Notes = new List<TakeRateDataItemNote>() { new TakeRateDataItemNote(Note) };
            }
            return dataItem;
        }
    }
}
