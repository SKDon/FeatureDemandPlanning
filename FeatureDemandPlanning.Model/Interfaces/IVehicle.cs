using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVehicle
    {
        int? VehicleId { get; set; }
        int? ProgrammeId { get; set; }
        int? GatewayId { get; set; }

        string Make { get; set; }
        string Code { get; set; }
        string Description { get; set;  }
        //string FullDescription { get; set; }
        string FullDescription { get; }
        string ModelYear { get; set; }
        string Gateway { get; set; }
        string ImageUri { get; set; }

        IList<ForecastTrimMapping> TrimMappings { get; set; }
        IEnumerable<Programme> Programmes { get; set; }
        IEnumerable<OXODoc> AvailableDocuments { get; set; }
        IEnumerable<TakeRateSummary> AvailableImports { get; set; }
        IEnumerable<Model> AvailableModels { get; set; }
        IEnumerable<MarketGroup> AvailableMarketGroups { get; set; }
        //IEnumerable<Market> AvailableMarkets { get; set; }

        Programme GetProgramme();
        IEnumerable<ModelTrim> ListTrimLevels();
    }
}
