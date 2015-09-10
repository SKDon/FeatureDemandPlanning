using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class TrimMapping
    {
        public ModelTrim ForecastVehicleTrim { get; set; }
        public IList<ModelTrim> ComparisonVehicleTrimMappings { get; set; }
    }
}
