using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Validators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ForecastTrim
    {
        public Vehicle ForecastVehicle { get; set; }
        public ForecastTrimMapping TrimMapping { get; set; }
        public VehicleWithIndex ComparisonVehicle { get; set; }
    }
}