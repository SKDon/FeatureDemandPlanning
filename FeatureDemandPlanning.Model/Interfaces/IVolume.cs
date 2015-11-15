using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVolume
    {
        OXODoc Document { get; set; }
        Vehicle Vehicle { get; set; }

        Market Market { get; set; }
        MarketGroup MarketGroup { get; set; }

        TakeRateResultMode Mode { get; set; }

        int TotalDerivatives { get; set; }

        IEnumerable<TakeRateSummary> VolumeSummary { get; set; }
        TakeRateData TakeRateData { get; set; }
    }
}
