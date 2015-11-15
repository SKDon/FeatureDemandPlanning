using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class ForecastVehicle : Vehicle
    {
        public IEnumerable<ModelTrim> TrimLevels { get; set; }

        private IEnumerable<ModelTrim> _programmes = new List<ModelTrim>();
    }
}