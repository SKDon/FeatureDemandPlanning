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

		[HttpPost]
		public ActionResult ForecastComparisonPage(Forecast forecast, int pageIndex)
		{
			var view = string.Empty;
			
			switch (pageIndex)
			{
				case 0:
					view = "_ForecastVehicle";
					break;
				case 1:
					view = "_ForecastComparison";
					break;
				case 2:
					view = "_ForecastTrim";
					break;
				default:
					view = "_ForecastVehicle";
					break;
			}

			return PartialView(view, GetFullAndPartialForecastComparisonViewModel(forecast));
		}

		
		public ActionResult ValidationMessage(ValidationMessage message)
		{
			// Something is making a GET request to this page and I can't figure out what
            return PartialView("_ValidationMessage", message);
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
        public ActionResult ForecastTrimSelect( Forecast forecast, 
                                                int vehicleIndex, 
                                                int forecastTrimId)
        {
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecast);

            ViewBag.ComparisonVehicle = forecastComparisonModel
                .NonEmptyComparisonVehicles
                .Where(v => v.VehicleIndex == vehicleIndex)
                .First();

            ViewBag.ForecastTrim = forecastComparisonModel.Forecast.ForecastVehicle.TrimMappings
                .Where(t => t.ForecastVehicleTrim.Id == forecastTrimId)
                .Select(t => t.ForecastVehicleTrim)
                .First();

            return PartialView("_ForecastTrimSelect", forecastComparisonModel);
        }

        [HttpPost]
        public ActionResult ForecastTrimMapping(Forecast forecast,
                                                int vehicleIndex,
                                                int forecastTrimId)
        {
            var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecast);

            ViewBag.ComparisonVehicle = forecastComparisonModel
                .NonEmptyComparisonVehicles
                .Where(v => v.VehicleIndex == vehicleIndex)
                .First();

            ViewBag.ForecastTrim = forecastComparisonModel.Forecast.ForecastVehicle.TrimMappings
                .Where(t => t.ForecastVehicleTrim.Id == forecastTrimId)
                .Select(t => t.ForecastVehicleTrim)
                .First();

            return PartialView("_ForecastTrimMapping", forecastComparisonModel);
        }

		[HttpPost]
		public ActionResult ValidateForecast(Forecast forecastToValidate, 
											 ForecastValidationSection sectionToValidate = ForecastValidationSection.All)
		{
			var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecastToValidate);
			var validator = new ForecastValidator((Forecast)forecastComparisonModel.Forecast);
			var ruleSets = ForecastValidator.GetRulesetsToValidate(sectionToValidate);
			var jsonResult = new JsonResult()
			{
				Data = new { IsValid = true }
			};

			var results = validator.Validate((Forecast)forecastComparisonModel.Forecast, ruleSet: ruleSets);
			if (!results.IsValid)
			{
				var errorModel = results.Errors.Select(e => new ValidationError()
				{
					key = e.PropertyName,
					errors = new List<ValidationErrorItem>() 
					{ 
						new ValidationErrorItem()
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
					Data = new ValidationMessage() { IsValid = false, Errors = errorModel.ToList() }
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
		private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel(ForecastFilter filter)
		{
			IForecast forecast = new EmptyForecast();
			if (filter.ForecastId.HasValue)
			{
				forecast = DataContext.Forecast.GetForecast(filter);
			}
			return GetFullAndPartialForecastComparisonViewModel(forecast);
		}
		private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel(IForecast forecast)
		{
			var forecastComparisonModel = new ForecastComparisonViewModel(DataContext)
			{
				Forecast = forecast,
				PageSize = PageSize,
				PageIndex = PageIndex
			};

			HydrateForecastVehicleTrimMapping(forecast);
			HydrateComparisonVehiclesTrimMappings(forecast);
			HydrateLookups(forecast, forecastComparisonModel);

			return forecastComparisonModel;
		}
		private void HydrateForecastVehicleTrimMapping(IForecast forecast)
		{
			if (forecast.ForecastVehicle.TrimMappings.Any() || !forecast.ForecastVehicle.Programmes.Any())
				return;

			var programme = forecast.ForecastVehicle.Programmes.First();

			forecast.ForecastVehicle.TrimMappings = programme.AllTrims
				.Select(t => new TrimMapping()
				{
					ForecastVehicleTrim = t,
					ComparisonVehicleTrimMappings = new List<ModelTrim>()
				}).ToList();
		}
		private void HydrateComparisonVehiclesTrimMappings(IForecast forecast)
		{
			if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
				return;

			foreach (var comparisonVehicle in forecast.ComparisonVehicles)
			{
				HydrateComparisonVehicleTrimMappings(forecast, comparisonVehicle);
			}
		}
		private void HydrateComparisonVehicleTrimMappings(IForecast forecast, IVehicle comparisonVehicle)
		{
			if (comparisonVehicle.TrimMappings.Any() || !forecast.ForecastVehicle.Programmes.Any())
				return;

			var programme = forecast.ForecastVehicle.Programmes.First();

			comparisonVehicle.TrimMappings = programme.AllTrims
				.Select(t => new TrimMapping() {
					ForecastVehicleTrim = t,
					ComparisonVehicleTrimMappings = new List<ModelTrim>()
				}).ToList();

			// TO DO, get the trim mappings if anything has been saved to the database
		}
		private void HydrateLookups(IForecast forecast, ForecastComparisonViewModel forecastComparisonModel)
		{
			forecastComparisonModel.ForecastVehicleLookup = new Lookup(DataContext, forecast.ForecastVehicle);

			foreach (var comparisonVehicle in forecast.ComparisonVehicles)
			{
				forecastComparisonModel.ComparisonVehicleLookup.Add(new Lookup(DataContext, comparisonVehicle));
			}
		}
	}
}