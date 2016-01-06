using System;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateDataItemNote
    {
        public int? FdpTakeRateDataItemNoteId { get; set; }
        public int? FdpTakeRateDataItemId { get; set; }
        public DateTime EnteredOn { get; set; }
        public string EnteredBy { get; set; }
        public string Note { get; set; }

        public int? MarketId { get; set; }
        public int? MarketGroupId { get; set; }
        public int? ModelId { get; set; }
        public int? FdpModelId { get; set; }
        public int? FeatureId { get; set; }
        public int? FdpFeatureId { get; set; }

        public string ModelIdentifier
        {
            get {
                return ModelId.HasValue ? string.Format("O{0}", ModelId) : string.Format("F{0}", FdpModelId);
            }
        }

        public string FeatureIdentifier
        {
            get {
                return FeatureId.HasValue ? string.Format("O{0}", FeatureId) : string.Format("F{0}", FdpFeatureId);
            }
        }

        public TakeRateDataItemNote()
        {

        }
        public TakeRateDataItemNote(string note)
        {
            Note = note;
        }
    }
}
