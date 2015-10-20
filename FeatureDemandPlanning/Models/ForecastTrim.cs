using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Validators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class ForecastTrim
    {
        public Vehicle ForecastVehicle { get; set; }
        public ForecastTrimMapping TrimMapping { get; set; }
        public VehicleWithIndex ComparisonVehicle { get; set; }
    }
}