namespace FeatureDemandPlanning.Model
{
    public class FdpOxoDoc
    {
        public int? FdpOxoDocId { get; set; }

        public TakeRateSummary Header 
        { 
            get 
            { 
                return _header; 
            } 
            set 
            { 
                _header = value; 
            } 
        }

        public OXODoc Document
        {
            get
            {
                return _document;
            }
            set
            {
                _document = value;
            }
        }

        private TakeRateSummary _header = new EmptyVolumeHeader();
        private OXODoc _document = new EmptyOxoDocument();
    }
}
