using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IForecastDataContext
    {
        IForecast GetForecast(ForecastFilter filter);
        IForecast SaveForecast(IForecast forecastToSave);
        IForecast DeleteForecast(IForecast forecastToDelete);

        PagedResults<IForecast> ListForecasts(ForecastFilter filter);
    }
}
