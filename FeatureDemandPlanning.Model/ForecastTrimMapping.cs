using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
