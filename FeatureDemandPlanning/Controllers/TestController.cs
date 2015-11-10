using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class TestController : ControllerBase
    {
        public async Task<ActionResult> Forecast(int? forecastId)
        {
            if (forecastId.HasValue)
            {
                RedirectToAction("GetForecast", new { forecastId = forecastId.Value } );
            }

            return View("Forecast", await GetFullOrPartialViewModelAsync(new ForecastFilter()));
        }

        public async Task<ActionResult> GetForecast(int forecastId)
        {
            try
            {
                var model = await GetFullOrPartialViewModelAsync(new ForecastFilter(forecastId));

                if (Request.IsAjaxRequest())
                {
                    return Json(model, JsonRequestBehavior.AllowGet);
                }
                
                return View("Forecast", model.Forecast);
            }
            catch (ApplicationException ex)
            {
                throw ex;
            }
        }

        [ChildActionOnly]
        public async Task<ActionResult> ListForecasts(ForecastFilter filter)
        {
            try
            {
                var model = await GetFullOrPartialViewModelAsync(filter);

                if (Request.IsAjaxRequest())
                {
                    return Json(model.Forecasts, JsonRequestBehavior.AllowGet);
                }

                return PartialView("ListForecasts", model);
            }
            catch (ApplicationException ex)
            {
                throw ex;
            }
        }

        //public async Task<ActionResult> SaveForecast(Forecast forecastToSave)
        //{
        //    try
        //    {
        //        var result = this.DataContext.Forecast.SaveForecast(forecastToSave);
        //        var model = await GetFullOrPartialViewModelAsync(new ForecastFilter(result.ForecastId));

        //        if (Request.IsAjaxRequest())
        //        {
        //            return Json(model.Forecast, JsonRequestBehavior.AllowGet);           
        //        }

        //        return View("Forecast", model.Forecast);
        //    }
        //    catch (ApplicationException ex)
        //    {
        //        throw ex;
        //    }
        //}

        public async Task<ActionResult> DeleteForecast(Forecast forecastToDelete)
        {
            try
            {
                var model = await GetFullOrPartialViewModelAsync(new ForecastFilter(forecastToDelete.ForecastId));
                var result = await this.DataContext.Forecast.DeleteForecastAsync(forecastToDelete);
               
                if (Request.IsAjaxRequest())
                {
                    return Json(model.Forecast, JsonRequestBehavior.AllowGet);
                }

                return View("Forecast");
            }
            catch (Exception)
            {
                
                throw;
            }
        }

        private async Task<ForecastComparisonViewModel> GetFullOrPartialViewModelAsync(ForecastFilter filter)
        {
            IForecast forecast = new EmptyForecast();
            PagedResults<ForecastSummary> forecasts = new PagedResults<ForecastSummary>();

            if (filter.ForecastId.HasValue)
            {
                forecast = await this.DataContext.Forecast.GetForecast(filter);
            }
            else
            {
                forecasts = await this.DataContext.Forecast.ListForecasts(filter);
            }

            var forecastComparisonModel = new ForecastComparisonViewModel()
            {
                Forecast = forecast,
                Forecasts = forecasts,
                PageSize = PageSize,
                PageIndex = PageIndex
            };

            return forecastComparisonModel;
        }
    }
}