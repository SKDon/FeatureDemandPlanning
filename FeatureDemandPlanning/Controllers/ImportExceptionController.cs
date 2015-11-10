using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Results;
using System;
using System.Threading.Tasks;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportExceptionController : ControllerBase
    {
        public ImportExceptionController() : base(ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult ImportExceptionsPage(int importQueueId)
        {
            return RedirectToAction("ImportExceptionsPage", new ImportExceptionParameters() { ImportQueueId = importQueueId });
        }
        [HttpGet]
        public async Task<ActionResult> ImportExceptionsPage(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var importView = await ImportViewModel.GetModel(DataContext,
                                    new ImportQueueFilter(parameters.ImportQueueId.Value)
                                    {
                                        ExceptionType = parameters.ExceptionType,
                                        PageIndex = PageIndex,
                                        PageSize = PageSize,
                                        Action = ImportAction.ImportQueueItem
                                    });

            return View(importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListImportExceptions(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var filter = new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault())
            {
                ExceptionType = parameters.ExceptionType,
                FilterMessage = parameters.FilterMessage,
                Action = ImportAction.ImportQueueItem
            };
            filter.InitialiseFromJson(parameters);

            var results = await ImportViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (!results.HasExceptions()) return Json(jQueryResult);
            jQueryResult.TotalSuccess = results.Exceptions.TotalSuccess;
            jQueryResult.TotalFail = results.Exceptions.TotalFail;

            foreach (var result in results.Exceptions.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }
            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifier);

            var importView = await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault()));

            return PartialView("_ContextMenu", importView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            var importView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithActionAndProgramme);
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingDerivative(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingFeature(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingTrim(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddSpecialFeature(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingDerivative(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingFeature(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingTrim(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingMarket(ImportExceptionParameters parameters)
        {
            var importView = await GetModelFromParameters(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> IgnoreException(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);

            importView.CurrentException = await DataContext.Import.IgnoreException(filter);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }

        #region "Private Methods"

        private async Task<ImportViewModel> GetModelFromParameters(ImportExceptionParameters parameters)
        {
            return await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value),
                parameters.Action);
        }
       
        #endregion
    }
}