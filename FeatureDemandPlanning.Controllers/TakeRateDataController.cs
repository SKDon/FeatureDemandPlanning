using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using System.Linq;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using MvcSiteMapProvider.Web.Mvc.Filters;
using System;
using System.Reflection;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling viewing / editing and updating of take rate information
    /// </summary>
    public class TakeRateDataController : ControllerBase
    {
        #region "Constructors"

        public TakeRateDataController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }

        #endregion

        [HttpGet]
        [ActionName("Index")]
        [SiteMapTitle("DocumentName")]
        public async Task<ActionResult> TakeRateDataPage(TakeRateParameters parameters)
        {
            Log.Debug(MethodBase.GetCurrentMethod().Name);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = await TakeRateViewModel.GetModel(DataContext, filter);

            ViewData["DocumentName"] = model.Document.UnderlyingOxoDocument.Name;
            ViewBag.Title = string.Format("{0} - {1} ({2}) - {3}", model.Document.Vehicle.Code,
                model.Document.Vehicle.ModelYear, model.Document.UnderlyingOxoDocument.Gateway, model.Document.TakeRateSummary.First().Version);

            return View("TakeRateDataPage", model);
        }
        [HttpPost]
        public async Task<ActionResult> TakeRateDataPartialPage(TakeRateParameters parameters)
        {
            Log.Debug(MethodBase.GetCurrentMethod().Name);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = await TakeRateViewModel.GetModel(DataContext, filter);

            ViewData["DocumentName"] = model.Document.UnderlyingOxoDocument.Name;
            ViewBag.Title = string.Format("{0} - {1} ({2}) - {3}", model.Document.Vehicle.Code,
                model.Document.Vehicle.ModelYear, model.Document.UnderlyingOxoDocument.Gateway, model.Document.TakeRateSummary.First().Version);

            return PartialView("_TakeRateData", model);       
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataItemDetails;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

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
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> SaveChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            await CheckModelAllowsEdit(parameters);

            var savedChangeset = await DataContext.TakeRate.SaveChangeset(TakeRateFilter.FromTakeRateParameters(parameters), parameters.Changeset);

            return Json(savedChangeset);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> GetLatestChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var changeset = await DataContext.TakeRate.GetUnsavedChangesForUser(TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(changeset);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> RevertLatestChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            await CheckModelAllowsEdit(parameters);

            var changeset = await DataContext.TakeRate.RevertUnsavedChangesForUser(TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(changeset);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> ChangesetHistory(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            takeRateView.History = await DataContext.TakeRate.GetChangesetHistory(filter);

            return PartialView("_ChangesetHistory", takeRateView);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> Filter(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Filter;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            return PartialView("_Filter", takeRateView);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> PersistChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangesetAndComment);

            await CheckModelAllowsEdit(parameters);

            var persistedChangeset = await DataContext.TakeRate.PersistChangeset(
                TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(persistedChangeset);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> PersistChangesetConfirm(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataItemDetails;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            takeRateView.Changes = await DataContext.TakeRate.GetUnsavedChangesForUser(filter);

            return PartialView("_PersistChangesetConfirm", takeRateView);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> UndoChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NO_EDITS);
            }
            var undoneChangeset = await DataContext.TakeRate.UndoChangeset(TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(undoneChangeset);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddNote(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.ModelPlusFeatureAndComment);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.AddNote;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NO_EDITS);
            }
            var note = await DataContext.TakeRate.AddDataItemNote(TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(note, JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> GetValidation(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var validation =
                await DataContext.TakeRate.GetValidation(TakeRateFilter.FromTakeRateParameters(parameters));

            return Json(validation);
        }
        
        public ActionResult ValidationMessage(ValidationMessage message)
        {
            // Something is making a GET request to this page and I can't figure out what
            return PartialView("_ValidationMessage", message);
        }

        #region "Private Methods"

        private async Task CheckModelAllowsEdit(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NO_EDITS);
            }
        }
        private async Task<TakeRateViewModel> GetModelFromParameters(TakeRateParameters parameters)
        {
            return await TakeRateViewModel.GetModel(
                DataContext,
                TakeRateFilter.FromTakeRateParameters(parameters));
        }

        #endregion

        #region "Private Constants"

        private const string NO_EDITS =
            "Either you do not have permission, or the take rate file does not allow edits in the current state";

        #endregion
    }
}