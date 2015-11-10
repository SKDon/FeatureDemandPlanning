using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using System.Web.Caching;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Results;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System.Net;


namespace FeatureDemandPlanning.Controllers
{
	public class ForecastController : ControllerBase
	{
		public ForecastController() : base()
		{
			ControllerType = ControllerType.SectionChild;
		}

		[HttpGet]
        [ActionName("Index")]
		public ActionResult ForecastPage(int? forecastId)
		{
            return RedirectToAction("ForecastPage", new ForecastParameters() { ForecastId = forecastId });
		}
        [HttpGet]
        public async Task<ActionResult> ForecastPage(ForecastParameters parameters)
        {
            ValidateForecastParameters(parameters, ForecastParametersValidator.NoValidation);

            var forecastView = await ForecastComparisonViewModel.GetModel(DataContext, 
                new ForecastFilter(parameters.ForecastId));

            return View(forecastView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListForecasts(ForecastParameters parameters)
        {
            ValidateForecastParameters(parameters, ForecastParametersValidator.NoValidation);

            var js = new JavaScriptSerializer();
            var filter = new ForecastFilter()
            {
                FilterMessage = parameters.FilterMessage
            };
            filter.InitialiseFromJson(parameters);

            var results = await ForecastComparisonViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Forecasts.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
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
		public async Task<ActionResult> Forecast(int? pageIndex, int? forecastId)
		{
			var filter = new ForecastFilter();
			filter.ForecastId = forecastId;
			var forecastComparisonModel = await GetFullAndPartialForecastComparisonViewModel(filter);
			forecastComparisonModel.PageIndex = pageIndex.GetValueOrDefault();

			ViewBag.PageTitle = "Edit Forecast";
			
			return View("ForecastComparison", forecastComparisonModel);
		}

		[HttpPost]
		public async Task<ActionResult> ForecastComparison(ForecastFilter filter)
		{
			var forecastComparisonModel = await GetFullAndPartialForecastComparisonViewModel(filter);

			if (forecastComparisonModel.Forecast.ForecastVehicle == null)
			{
				forecastComparisonModel.SetProcessState(
					new Model.ProcessState(FeatureDemandPlanning.Model.Enumerations.ProcessStatus.Warning, "No programmes available matching search criteria"));
			}

			return View("ForecastComparison", forecastComparisonModel);
		}

		[HttpPost]
		public ActionResult ForecastTrimSelect( Forecast forecast, 
												int vehicleIndex, 
												int forecastTrimId)
		{
			var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecast);
			
			var comparisonVehicle = forecastComparisonModel
				.NonEmptyComparisonVehicles
				.Where(v => v.VehicleIndex == vehicleIndex)
				.First();
			var forecastTrim = forecastComparisonModel.Forecast.ForecastVehicle.TrimMappings
				.Where(t => t.ForecastVehicleTrim.Id == forecastTrimId)
				.Select(t => t.ForecastVehicleTrim)
				.First();
			var configuredMappings = Enumerable.Empty<ModelTrim>();

			if (comparisonVehicle.Vehicle.TrimMappings.Any())
			{
				var mappings = comparisonVehicle.Vehicle.TrimMappings.Where(m => m.ForecastVehicleTrim.Id == forecastTrim.Id).FirstOrDefault();
				if (mappings != null)
				{
					configuredMappings = mappings.ComparisonVehicleTrimMappings;
				}
			}

			ViewBag.ComparisonVehicle = comparisonVehicle;
			ViewBag.ForecastTrim = forecastTrim;
			ViewBag.ConfiguredMappings = configuredMappings;

			return PartialView("_ForecastTrimSelect", forecastComparisonModel);
		}

		[HttpPost]
		public ActionResult ForecastTrimMapping(Forecast forecast,
												int vehicleIndex,
												int forecastTrimId)
		{
			var forecastComparisonModel = GetFullAndPartialForecastComparisonViewModel(forecast);

			var comparisonVehicle = forecastComparisonModel
				.NonEmptyComparisonVehicles
				.Where(v => v.VehicleIndex == vehicleIndex)
				.First();
			var forecastTrim = forecastComparisonModel.Forecast.ForecastVehicle.TrimMappings
				.Where(t => t.ForecastVehicleTrim.Id == forecastTrimId)
				.Select(t => t.ForecastVehicleTrim)
				.First();
			var configuredMappings = Enumerable.Empty<ModelTrim>();

			if (comparisonVehicle.Vehicle.TrimMappings.Any())
			{
				var mappings = comparisonVehicle.Vehicle.TrimMappings.Where(m => m.ForecastVehicleTrim.Id == forecastTrim.Id).FirstOrDefault();
				if (mappings != null)
				{
					configuredMappings = mappings.ComparisonVehicleTrimMappings;
				}
			}

			ViewBag.ComparisonVehicle = comparisonVehicle;
			ViewBag.ForecastTrim = forecastTrim;
			ViewBag.ConfiguredMappings = configuredMappings;

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
                var errorModel = results.Errors.Select(e => new ValidationError(new ValidationErrorItem(e.ErrorMessage, e.CustomState))
				{
					key = e.PropertyName
				});

				jsonResult = new JsonResult()
				{
					Data = new ValidationMessage(false, errorModel)
				};
			}
			return jsonResult;
		}
		
        //[HttpPost]
        //[ValidateAjax]
        //public JsonResult SaveForecast(Forecast forecastToSave)
        //{
        //    var processState = new ProcessState();
        //    var model = GetFullAndPartialForecastComparisonViewModel();
        //    var result = GetResult(processState, model);
			
        //    try
        //    {
        //        if (!ModelState.IsValid)
        //        {
        //            return GetResult(processState, model);
        //        }
				
        //        forecastToSave = (Forecast)DataContext.Forecast.SaveForecast(forecastToSave);
        //        if (!forecastToSave.IsPersisted(processState))
        //        {
        //            return GetResult(processState, model);
        //        }
			   
        //        model = GetFullAndPartialForecastComparisonViewModel(forecastToSave);
        //        processState.AddMessage("Forecast saved successfully");
        //    }
        //    catch (ApplicationException ex)
        //    {
        //        processState = ProcessState.FromException("An error occurred saving the forecast", ex);
        //    }
        //    finally
        //    {
        //        if (processState.Status == FeatureDemandPlanning.Model.Enumerations.ProcessStatus.Failure)
        //        {
        //            Response.StatusCode = (int)HttpStatusCode.InternalServerError;
        //        }
        //        result = GetResult(processState, model);
        //    }

        //    return result;
        //}

		private JsonResult GetResult(ProcessState processState, ForecastComparisonViewModel model)
		{
			model.SetProcessState(processState);
			return Json(model);
		}
		private async Task<ForecastComparisonViewModel> GetFullAndPartialForecastComparisonViewModel()
		{
			return await GetFullAndPartialForecastComparisonViewModel(new ForecastFilter());
		}
		private async Task<ForecastComparisonViewModel> GetFullAndPartialForecastComparisonViewModel(ForecastFilter filter)
		{
			IForecast forecast = new EmptyForecast();
			if (filter.ForecastId.HasValue)
			{
				forecast = await DataContext.Forecast.GetForecast(filter);
			}
			return GetFullAndPartialForecastComparisonViewModel(forecast);
		}
		private ForecastComparisonViewModel GetFullAndPartialForecastComparisonViewModel(IForecast forecast)
		{
			var forecastComparisonModel = new ForecastComparisonViewModel()
			{
				Forecast = forecast,
				PageSize = PageSize,
				PageIndex = PageIndex
			};

			HydrateLookups(forecast, forecastComparisonModel);
			HydrateForecastVehicleTrimMapping(forecast);
			HydrateComparisonVehiclesTrimMappings(forecast);

			return forecastComparisonModel;
		}
		private static void HydrateForecastVehicleTrimMapping(IForecast forecast)
		{
			if (forecast.ForecastVehicle.TrimMappings.Any() || !forecast.ForecastVehicle.Programmes.Any())
				return;

			var programme = forecast.ForecastVehicle.Programmes.First();

			forecast.ForecastVehicle.TrimMappings = programme.AllTrims
				.Select(t => new ForecastTrimMapping()
				{
					ForecastVehicleTrim = t,
					ComparisonVehicleTrimMappings = new List<ModelTrim>()
				}).ToList();
		}
		private static void HydrateComparisonVehiclesTrimMappings(IForecast forecast)
		{
			if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
				return;

			foreach (var comparisonVehicle in forecast.ComparisonVehicles)
			{
				HydrateComparisonVehicleTrimMappings(forecast, comparisonVehicle);
			}
		}
		private static void HydrateComparisonVehicleTrimMappings(IForecast forecast, IVehicle comparisonVehicle)
		{
			if (!forecast.ForecastVehicle.Programmes.Any())
				return;

			var programme = forecast.ForecastVehicle.Programmes.First();

			if (comparisonVehicle.TrimMappings.Any())
			{
				// If we have trim mappings, we may only have the identifiers, we need the full descriptive information
				// So fill in the missing information

				foreach (var existingTrimMapping in comparisonVehicle.TrimMappings)
				{
					// Get the fully populated forecast trim
					var forecastVehicleTrim = programme.AllTrims.Where(t => t.Id == existingTrimMapping.ForecastVehicleTrim.Id).First();
					existingTrimMapping.ForecastVehicleTrim = forecastVehicleTrim;

					// Build a list of fully populated comparison trim
					var newComparisonVehicleTrimMappings = new List<ModelTrim>();
					foreach (var comparisonVehicleTrimMapping in existingTrimMapping.ComparisonVehicleTrimMappings)
					{
						newComparisonVehicleTrimMappings.Add(comparisonVehicle.ListTrimLevels()
							.Where(t => t.Id == comparisonVehicleTrimMapping.Id).First());
					}
					existingTrimMapping.ComparisonVehicleTrimMappings = newComparisonVehicleTrimMappings;
				}
			}
            else
            {
                // If the vehicle has no trim levels, we don't want to populate the trim mapping model
                var comparisonProgramme = comparisonVehicle.Programmes.FirstOrDefault();
                if (comparisonProgramme == null || !comparisonProgramme.AllTrims.Any())
                {
                    comparisonVehicle.TrimMappings = Enumerable.Empty<ForecastTrimMapping>().ToList();
                }
                else
                {
                    comparisonVehicle.TrimMappings = programme.AllTrims
                        .Select(t => new ForecastTrimMapping()
                        {
                            ForecastVehicleTrim = t,
                            ComparisonVehicleTrimMappings = new List<ModelTrim>()
                        }).ToList();
                }
            }

			// TO DO, get the trim mappings if anything has been saved to the database
		}
		private void HydrateLookups(IForecast forecast, ForecastComparisonViewModel forecastComparisonModel)
		{
			forecastComparisonModel.ForecastVehicleLookup = GetLookup(forecast.ForecastVehicle, HttpContext.Cache, DataContext);
            forecastComparisonModel.ComparisonVehicleLookup = new List<LookupViewModel>();
			foreach (var comparisonVehicle in forecast.ComparisonVehicles)
			{
				forecastComparisonModel.ComparisonVehicleLookup.Add(GetLookup(comparisonVehicle, HttpContext.Cache, DataContext));
			}
		}
		private static LookupViewModel GetLookup(IVehicle forVehicle, Cache cache, IDataContext dataContext)
		{
            LookupViewModel lookup = null;
			var cacheKey = string.Format("ProgrammeLookup_{0}", forVehicle.GetHashCode());
			var cachedLookup = cache.Get(cacheKey);
			if (cachedLookup != null) {
                lookup = (LookupViewModel)cachedLookup;
			}
			else {
                lookup = LookupViewModel.GetModelForVehicle(forVehicle, dataContext);
				cache.Add(cacheKey, lookup, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
			}
			return lookup;
		}
        private void ValidateForecastParameters(ForecastParameters parameters, string ruleSetName)
        {
            var validator = new ForecastParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
	}

    internal class ForecastParametersValidator : AbstractValidator<ForecastParameters>
    {
        public const string ForecastIdentifier = "FORECAST_ID";
        public const string NoValidation = "NO_VALIDATION";

        public ForecastParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(ForecastIdentifier, () =>
            {
                RuleFor(p => p.ForecastId).NotNull().WithMessage("'ForecastId' not specified");
            });
        }
    }
}