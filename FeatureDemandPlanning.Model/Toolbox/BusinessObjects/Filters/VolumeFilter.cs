using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    public class VolumeFilter
    {
        public int? OxoDocId { get; set; }
        public int? FdpVolumeHeaderId { get; set; }
        public int? ProgrammeId { get; set; }
        public int? MarketId { get; set; }
        public int? MarketGroupId { get; set; }
        public string Gateway { get; set; }

        public VolumeResultMode Mode
        {
            get
            {
                return _resultMode;
            }
            set 
            {
                _resultMode = value;
            } 
        }

        public IEnumerable<Model> Models 
        { 
            get 
            {
                return _models;
            } 
            set 
            { 
                _models = value; 
            } 
        }

        public static VolumeFilter FromVolume(IVolume volume)
        {
            var filter = new VolumeFilter()
            {
                ProgrammeId = volume.Vehicle.ProgrammeId,
                Gateway = volume.Vehicle.Gateway
            };

            if (!(volume.Document is EmptyOxoDocument))
                filter.OxoDocId = volume.Document.Id;

            if (!(volume.Market is EmptyMarket))
                filter.MarketId = volume.Market.Id;

            if (!(volume.MarketGroup is EmptyMarketGroup))
                filter.MarketGroupId = volume.MarketGroup.Id;

            if (!(volume.Vehicle is EmptyVehicle))
                filter.Models = volume.Vehicle.AvailableModels;

            filter.Mode = volume.Mode;

            return filter;
        }

        private IEnumerable<Model> _models = Enumerable.Empty<Model>();
        private VolumeResultMode _resultMode = VolumeResultMode.Raw;
    }
}
