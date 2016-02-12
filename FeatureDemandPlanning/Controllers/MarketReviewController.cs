using System;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Controllers
{
    public class MarketReviewController : ControllerBase
    {
        public MarketReviewController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult MarketReviewPage()
        {
            return RedirectToAction("MarketReviewPage");
        }
        [HttpGet]
        [OutputCacheComplex(typeof(TakeRateParameters))]
        public async Task<ActionResult> MarketReviewPage(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            return View(await MarketReviewViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListMarketReview(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.NoValidation);

            var filter = new TakeRateFilter()
            {
                FilterMessage = parameters.FilterMessage,
                Action = TakeRateDataItemAction.MarketReview
            };
            filter.InitialiseFromJson(parameters);

            var results = await MarketReviewViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.AvailableMarketReviews.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> MarketReview(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithCommentAndMarketAndReviewStatus);

            await CheckModelAllowsEdit(parameters);

            var marketReview = await DataContext.TakeRate.SetMarketReview(
                TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(marketReview);
        }
        [HandleErrorWithJson]
        [HttpPost]
        [OutputCacheComplex(typeof(TakeRateParameters))]
        public async Task<ActionResult> MarketReviewConfirm(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.MarketReview;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            takeRateView.Changes = await DataContext.TakeRate.GetUnsavedChangesForUser(filter);

            return PartialView("_MarketReviewConfirm", takeRateView);
        }
        private async Task CheckModelAllowsEdit(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
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