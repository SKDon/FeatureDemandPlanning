using System;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using System.Web.Mvc;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Controllers
{
    public class PublishController : ControllerBase
    {
        public PublishController(IDataContext context)
            : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult PublishPage()
        {
            return RedirectToAction("PublishPage");
        }
        [HttpGet]
        [OutputCacheComplex(typeof(TakeRateParameters))]
        public async Task<ActionResult> PublishPage(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            return View(await PublishViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListPublish(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.NoValidation);

            var filter = new TakeRateFilter()
            {
                FilterMessage = parameters.FilterMessage,
                Action = TakeRateDataItemAction.Publish
            };
            filter.InitialiseFromJson(parameters);

            var results = await PublishViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.AvailableFiles.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> Publish(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithCommentAndMarket);

            var publish = await DataContext.TakeRate.SetPublish(
                TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(publish);
        }
        [HandleErrorWithJson]
        [HttpPost]
        //[OutputCacheComplex(typeof(TakeRateParameters))]
        public async Task<ActionResult> PublishConfirm(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Publish;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            return PartialView("_PublishConfirm", takeRateView);
        }
        private async Task CheckModelAllowsEdit(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Publish;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NoEdits);
            }
        }

        #region "Private Constants"

        private const string NoEdits =
            "Either you do not have permission, or the take rate file does not allow edits in the current state";

        #endregion
    }
}