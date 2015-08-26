using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    public class ForecastFilter : FilterBase
    {
        public int? ForecastId { get; set; }

        public ForecastFilter()
        {
        }

        public ForecastFilter(Forecast forecast)
        {
            ForecastId = forecast.Id;
        }

        public ForecastFilter(int? forecastId)
        {
            ForecastId = forecastId;
        }
    }
}
