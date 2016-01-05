using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model
{
    public class FdpOxoDoc
    {
        public int? FdpOxoDocId { get; set; }
        public TakeRateSummary Header { get; set; }
        public OXODoc Document { get; set; }

        public FdpOxoDoc()
        {
            Header = new EmptyTakeRateSummary();
            Document = new EmptyOxoDocument();
        }
    }
}
