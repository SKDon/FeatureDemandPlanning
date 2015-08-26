using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class TrimMapping
    {
        public int? Id { get; set; }
        public int ForecastId { get; set; }
        public int VehicleIndex { get; set; }
        public int ForecastVehicleTrimId { get; set; }
        public int ComparisonVehicleProgrammeId { get; set; }
        public int? ComparisonVehicleTrimId { get; set; }
        
        public ModelTrim ForecastVehicleTrim { get; set; }
        public ModelTrim ComparisonVehicleTrim { get; set; }
    }
}
