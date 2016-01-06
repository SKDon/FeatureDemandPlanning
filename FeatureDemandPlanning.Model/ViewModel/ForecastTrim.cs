using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ForecastTrim
    {
        public Vehicle ForecastVehicle { get; set; }
        public ForecastTrimMapping TrimMapping { get; set; }
        public VehicleWithIndex ComparisonVehicle { get; set; }
    }
}