using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class ForecastTrimMapping
    {
        public ModelTrim ForecastVehicleTrim { get; set; }
        public IList<ModelTrim> ComparisonVehicleTrimMappings { get; set; }

        public ForecastTrimMapping()
        {
            ForecastVehicleTrim = new ModelTrim();
            ComparisonVehicleTrimMappings = Enumerable.Empty<ModelTrim>().ToList();
        }
    }
}
