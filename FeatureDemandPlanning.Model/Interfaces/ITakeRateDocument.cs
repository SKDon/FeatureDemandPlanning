using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
    }
}
