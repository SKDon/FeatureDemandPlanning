using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

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
            get
            {
                if (ModelId.HasValue)
                {
                    return string.Format("O{0}", ModelId);
                }
                else
                {
                    return string.Format("F{0}", FdpModelId);
                }
            }
        }

        public string FeatureIdentifier
        {
            get
            {
                if (FeatureId.HasValue)
                {
                    return string.Format("O{0}", FeatureId);
                }
                else
                {
                    return string.Format("F{0}", FdpFeatureId);
                }
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
