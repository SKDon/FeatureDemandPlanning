using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateData
    {
        public int TotalVolume { get; set; }
        public int FilteredVolume { get; set; }
        public decimal PercentageOfTotalVolume { get; set; }
        public decimal ModelMix { get; set; }
        public int ModelVolume { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public DataTable RawData { get; set; }
        public IEnumerable<DataRow> FeatureApplicabilityData { get; set; }
        public IEnumerable<ModelTakeRateSummary> TakeRateSummaryByModel { get; set; }
        public IEnumerable<TakeRateDataItemNote> NoteAvailability { get; set; }
        public IEnumerable<ExclusiveFeatureGroup> ExclusiveFeatureGroups { get; set; }
        public IEnumerable<PackFeature> PackFeatures { get; set; }
        public IEnumerable<RawPowertrainDataItem> PowertrainData { get; set; }
        public IEnumerable<MultiMappedFeatureGroup> MultiMappedFeatureGroups { get; set; } 

        public bool HasData
        {
            get { return RawData != null && RawData.AsEnumerable().Any(); }
        }

        public TakeRateData()
        {
            RawData = new DataTable();
            FeatureApplicabilityData = Enumerable.Empty<DataRow>();
            TakeRateSummaryByModel = Enumerable.Empty<ModelTakeRateSummary>();
            NoteAvailability = Enumerable.Empty<TakeRateDataItemNote>();
            ExclusiveFeatureGroups = Enumerable.Empty<ExclusiveFeatureGroup>();
            PowertrainData = Enumerable.Empty<RawPowertrainDataItem>();
            MultiMappedFeatureGroups = Enumerable.Empty<MultiMappedFeatureGroup>();
        }
    }
}
