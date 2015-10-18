using System;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class FdpOxoDoc
    {
        public int? FdpOxoDocId { get; set; }

        public FdpVolumeHeader Header 
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

        private FdpVolumeHeader _header = new EmptyVolumeHeader();
        private OXODoc _document = new EmptyOxoDocument();
    }
}
