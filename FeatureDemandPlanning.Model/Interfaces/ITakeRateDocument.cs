using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface ITakeRateDocument
    {
        OXODoc UnderlyingOxoDocument { get; set; }
        Vehicle Vehicle { get; set; }

        Market Market { get; set; }
        MarketGroup MarketGroup { get; set; }

        TakeRateResultMode Mode { get; set; }

        int TotalDerivatives { get; set; }

        IEnumerable<TakeRateSummary> TakeRateSummary { get; set; }
        TakeRateData TakeRateData { get; set; }

        int? PageIndex { get; set; }
        int? PageSize { get; set; }
    }
}
