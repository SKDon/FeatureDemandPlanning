using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class ForecastModel
    {
        public int? ForecastId { get; set; }

        public ForecastModel(IDataContext dataContext)
        {
            _dataContext = dataContext;
        }

        public IVehicle GetForecastVehicle()
        {
            var f
            return _dataContext.Forecast.GetForecast(ForecastId.Value).ForecastVehicle;
        }

        public IList<IVehicle> ListComparisonVehicles()
        {
            var forecast = _dataContext.Forecast.GetForecast(ForecastId.Value);

            return forecast.ComparisonVehicles.ToList();
        }

        private IDataContext _dataContext = null;
    }
}