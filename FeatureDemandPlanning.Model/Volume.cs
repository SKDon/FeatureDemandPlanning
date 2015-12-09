using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class Volume : IVolume
    {
        public OXODoc Document 
        { 
            get { return _document; }
            set 
            {
                if (value is EmptyOxoDocument && value.Id != 0)
                {
                    _document = new OXODoc() { Id = value.Id };
                } 
                else
                {
                    _document = value;
                }
            } 
        }

        public Market Market
        {
            get
            {
                return _market;
            }
            set
            {
                _market = value;
            }
        }

        public MarketGroup MarketGroup
        {
            get
            {
                return _marketGroup;
            }
            set
            {
                _marketGroup = value;
            }
        }

        public Vehicle Vehicle 
        { 
            get 
            { 
                return _vehicle; 
            } 
            set 
            { 
                if (value is EmptyVehicle && value.ProgrammeId.GetValueOrDefault() != 0)
                {
                    _vehicle = Vehicle.FromVehicle(value);
                }
                else
                {
                    _vehicle = value;
                }
            } 
        }

        public TakeRateData VolumeData
        {
            get
            {
                return _volumeData;
            }
            set
            {
                _volumeData = value;
            }
        }

        public TakeRateResultMode Mode
        {
            get
            {
                return _mode;
            }
            set
            {
                _mode = value;
            }
        }

        public int TotalDerivatives { get; set; }

        public static Volume FromFilter(VolumeFilter filter)
        {
            var volume = new Volume();

            if (filter.OxoDocId.HasValue) {
                volume.Document = new OXODoc() { Id = filter.OxoDocId.Value };
            }

            if (filter.ProgrammeId.HasValue) {
                volume.Vehicle = new Vehicle() { ProgrammeId = filter.ProgrammeId.Value, Gateway = filter.Gateway };
            }

            if (filter.MarketGroupId.HasValue) {
                volume.MarketGroup = new MarketGroup() { Id = filter.MarketGroupId.Value };
            }

            if (filter.MarketId.HasValue) {
                volume.Market = new Market() { Id = filter.MarketId.Value };
            }

            volume.Mode = filter.Mode;

            return volume;
        }

        public IEnumerable<TakeRateSummary> VolumeSummary { get { return _summary; } set { _summary = value; } }
        
        private IEnumerable<TakeRateSummary> _summary = new List<TakeRateSummary>();
        private Vehicle _vehicle = new EmptyVehicle();
        private OXODoc _document = new EmptyOxoDocument();
        private Market _market = new EmptyMarket();
        private MarketGroup _marketGroup = new EmptyMarketGroup();
        private TakeRateData _volumeData = new TakeRateData();
        private TakeRateResultMode _mode = TakeRateResultMode.PercentageTakeRate;
    }
}
