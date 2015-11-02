using System;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class FdpOxoVolumeDataItem
    {
        public int? FdpOxoVolumeDataItemId { get; set; }
        public string Section { get; set; }
        public int ModelId { get; set; }
        public int? MarketGroupId { get; set; }
        public int MarketId { get; set; }
        public int OxoDocId { get; set; }
        public int Volume { get; set; }
        public Single PercentageTakeRate { get; set; }
        public string CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime UpdatedOn { get; set; }
        public int? PackId { get; set; }

        public IList<FdpOxoVolumeDataItemNote> Notes
        {
            get
            {
                return _notes;
            }
            set
            {
                _notes = value;
            }
        }

        public IEnumerable<FdpOxoVolumeDataItemHistory> History
        {
            get
            {
                return _history;
            }
            set
            {
                _history = value;
            }
        }

        private IList<FdpOxoVolumeDataItemNote> _notes = new List<FdpOxoVolumeDataItemNote>();
        private IEnumerable<FdpOxoVolumeDataItemHistory> _history = new List<FdpOxoVolumeDataItemHistory>();
    }
}
