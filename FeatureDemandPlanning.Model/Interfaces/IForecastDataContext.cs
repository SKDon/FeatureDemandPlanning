using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IForecastDataContext
    {
        //IForecast GetForecast(ForecastFilter filter);
        //IForecast SaveForecast(IForecast forecastToSave);
        //IForecast DeleteForecast(IForecast forecastToDelete);

        Task<IForecast> GetForecast(ForecastFilter filter);
        Task<IForecast> SaveForecastAsync(IForecast forecastToSave);
        Task<IForecast> DeleteForecastAsync(IForecast forecastToDelete);

        //PagedResults<IForecast> ListForecasts(ForecastFilter filter);
        Task<PagedResults<ForecastSummary>> ListForecasts(ForecastFilter filter);
        Task<PagedResults<ForecastSummary>> ListLatestForecasts();
    }
}
