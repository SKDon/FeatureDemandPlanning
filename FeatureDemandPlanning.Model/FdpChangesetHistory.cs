using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class FdpChangesetHistory
    {
        public IEnumerable<FdpChangesetHistoryItem> History { get; set; }

        public FdpChangesetHistory()
        {
            History = Enumerable.Empty<FdpChangesetHistoryItem>();
        }
    }

    public class FdpChangesetHistoryDetails
    {
        public IEnumerable<FdpChangesetHistoryItemDetails> HistoryDetails { get; set; }

        public FdpChangesetHistoryDetails()
        {
            HistoryDetails = Enumerable.Empty<FdpChangesetHistoryItemDetails>();
        }
    }
}
