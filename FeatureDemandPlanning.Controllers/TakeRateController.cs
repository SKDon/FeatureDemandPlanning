using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using System;
using System.Web.Script.Serialization;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling take rate files
    /// </summary>
    public class TakeRateController : ControllerBase
    {
        #region "Constructors"

        public TakeRateController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }

        #endregion

        [ActionName("Index")]
        [HttpGet]
        public async Task<ActionResult> TakeRatePage(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.NoValidation);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRates;
            var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

            return View("TakeRatePage", takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTakeRates(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.NoValidation);

            var js = new JavaScriptSerializer();
            var filter = new TakeRateFilter()
            {
                FilterMessage = parameters.FilterMessage,
                TakeRateStatusId = parameters.TakeRateStatusId,
                Action = TakeRateDataItemAction.TakeRates
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
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

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
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }

        #region "Private Methods"

        private async Task<TakeRateViewModel> GetModelFromParameters(TakeRateParameters parameters)
        {
            return await TakeRateViewModel.GetModel(DataContext, TakeRateFilter.FromTakeRateParameters(parameters));
        }

        #endregion

        #region "Private Members"

        private PageFilter _pageFilter = new PageFilter();

        #endregion
    }
}