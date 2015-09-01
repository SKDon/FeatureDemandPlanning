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
using FeatureDemandPlanning.BusinessObjects.Validators;
using FeatureDemandPlanning.Enumerations;
using FluentValidation;
using FluentValidation.Internal;

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
            ViewBag.Title = "Forecasts";

            return RedirectToAction("Forecast");
        }

        [HttpGet]
        public ActionResult Forecast(int? viewPage, int? forecastId)
        {
            var filter = new ForecastFilter();
            filter.ForecastId = forecastId;
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(filter);
            forecastComparisonModel.ViewPage = viewPage.GetValueOrDefault();

            ViewBag.PageTitle = "Edit Forecast";
            
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
        public ActionResult ValidateForecast(Forecast forecastToValidate, 
                                             ForecastValidationSection sectionToValidate = ForecastValidationSection.All)
        {
            var validator = new ForecastValidator(forecastToValidate);
            var ruleSets = ForecastValidator.GetRulesetsToValidate(sectionToValidate);
            var jsonResult = new JsonResult()
            {
                Data = new { IsValid = true }
            };

            var results = validator.Validate(forecastToValidate, ruleSet: ruleSets);
            if (!results.IsValid)
            {
                var errorModel = results.Errors.Select(e => new
                {
                    key = e.PropertyName,
                    errors = new [] 
                    { 
                        new 
                        { 
                            ErrorMessage = e.ErrorMessage,
                            CustomState = e.CustomState//, 
                            //ProcessStatus = (FeatureDemandPlanning.Enumerations.ProcessStatus) e.CustomState == null 
                            //    ? FeatureDemandPlanning.Enumerations.ProcessStatus.Warning 
                            //    : e.CustomState 
                        }
                    }
                });

                jsonResult = new JsonResult()
                {
                    Data = new { IsValid = false, Errors = errorModel }
                };
            }
            return jsonResult;
        }
        
        [HttpPost]
        [ValidateAjax]
        public JsonResult SaveForecast(Forecast forecastToSave)
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