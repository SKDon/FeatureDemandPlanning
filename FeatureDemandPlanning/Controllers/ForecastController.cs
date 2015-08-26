using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using FeatureDemandPlanning.Model;
using System.Web.Caching;
using enums = FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.BusinessObjects;
using System.Net;

namespace FeatureDemandPlanning.Controllers
{
    public class ForecastController : ControllerBase
    {
        public ForecastController() : base()
        {
            ControllerType = Controllers.ControllerType.SectionChild;
        }

        [HttpGet]
        public ActionResult Index()
        {
            return RedirectToAction("Forecast");
        }

        [HttpGet]
        public ActionResult Forecast(int? viewPage, int? forecastId)
        {
            var filter = new ForecastFilter();
            filter.ForecastId = forecastId;
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(filter);
            forecastComparisonModel.ViewPage = viewPage.GetValueOrDefault();
            
            return View("Forecast", forecastComparisonModel);
        }

        [HttpPost]
        public ActionResult ForecastComparison(ForecastFilter filter)
        {
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(filter);

            if (forecastComparisonModel.Forecast.ForecastVehicle == null)
            {
                forecastComparisonModel.SetProcessState(
                    new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Warning, "No programmes available matching search criteria"));
            }

            return View("ForecastComparison", forecastComparisonModel);
        }

        [HttpPost]
        public ActionResult ValidateForecast(Forecast forecastToValidate)
        {
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecastToValidate);

            if (!ModelState.IsValid)
            {

            }

            return Json(forecastComparisonModel);
        }
        
        [HttpPost]
        public ActionResult SaveForecast(Forecast forecastToSave)
        {
            var processState = new ProcessState();
            var model = GetFullAndPartialForecastComparisonViewModel();
            var result = GetResult(processState, model);
            
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetResult(processState, model);
                }
                
                forecastToSave = (Forecast)DataContext.Forecast.SaveForecast(forecastToSave);
                if (!forecastToSave.IsPersisted(processState))
                {
                    return GetResult(processState, model);
                }
                
                model = GetFullAndPartialForecastComparisonViewModel(forecastToSave);
                processState.AddMessage("Forecast saved successfully");
            }
            catch (ApplicationException ex)
            {
                processState = ProcessState.FromException("An error occurred saving the forecast", ex);
            }
            finally
            {
                if (processState.Status == enums.ProcessStatus.Failure)
                {
                    Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                }
                result = GetResult(processState, model);
            }

            return result;
        }

        private JsonResult GetResult(ProcessState processState, ForecastComparisonViewModel model)
        {
            model.SetProcessState(processState);
            return Json(model);
        }

        private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel()
        {
            return GetFullAndPartialForecastComparisonViewModel(new ForecastFilter());
        }

        private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel(Forecast forecast)
        {
            return GetFullAndPartialForecastComparisonViewModel(new ForecastFilter(forecast.ForecastId));
        }

        private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel(ForecastFilter filter)
        {
            IForecast forecast = new EmptyForecast();
            if (filter.ForecastId.HasValue)
            {
                forecast = DataContext.Forecast.GetForecast(filter);
            }

            var forecastComparisonModel = new ForecastComparisonViewModel(DataContext)
            {
                Forecast = forecast,
                PageSize = PageSize,
                PageIndex = PageIndex
            };

            return forecastComparisonModel;
        }
    }
}