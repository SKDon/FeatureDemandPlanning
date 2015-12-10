using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System.Linq;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using System.Web.Script.Serialization;
using MvcSiteMapProvider.Web.Mvc.Filters;
using System;
using FeatureDemandPlanning.Model.Results;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling take rate files
    /// </summary>
    public class TakeRateController : ControllerBase
    {
        #region "Constructors"

        public TakeRateController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }

        #endregion

        [HttpGet]
        [ActionName("Index")]
        public ActionResult TakeRatePage()
        {
            return RedirectToAction("TakeRatePage", new TakeRateParameters());
        }
        [HttpGet]
        public async Task<ActionResult> TakeRatePage(TakeRateParameters parameters)
        {
            ValidateTakeRateParameters(parameters, TakeRateParametersValidator.NoValidation);

            var takeRateView = await TakeRateViewModel.GetModel(DataContext, new TakeRateFilter());

            return View(takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTakeRates(TakeRateParameters parameters)
        {
            ValidateTakeRateParameters(parameters, TakeRateParametersValidator.NoValidation);

            var js = new JavaScriptSerializer();
            var filter = new TakeRateFilter()
            {
                FilterMessage = parameters.FilterMessage,
                TakeRateStatusId = parameters.TakeRateStatusId
            };
            filter.InitialiseFromJson(parameters);

            var results = await TakeRateViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.TakeRates.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                TakeRateFilter.FromTakeRateId(parameters.TakeRateId.GetValueOrDefault()));

            return PartialView("_ContextMenu", takeRateView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }

        #region "Private Methods"

        private async Task<TakeRateViewModel> GetModelFromParameters(TakeRateParameters parameters)
        {
            return await TakeRateViewModel.GetModel(DataContext, TakeRateFilter.FromTakeRateParameters(parameters));
        }
        private static void ValidateTakeRateParameters(TakeRateParameters parameters, string ruleSetName)
        {
            var validator = new TakeRateParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }

        #endregion

        #region "Private Members"

        private PageFilter _pageFilter = new PageFilter();

        #endregion
    }
}