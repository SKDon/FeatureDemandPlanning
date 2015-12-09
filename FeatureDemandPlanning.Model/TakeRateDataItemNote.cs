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

        public TakeRateDataItemNote()
        {

        }
        public TakeRateDataItemNote(string note)
        {
            Note = note;
        }
    }
}
