using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Results;
using System;
using System.Linq;
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
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithActionProgrammeAndGateway);
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingDerivative(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var derivative = new FdpDerivative()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                DerivativeCode = parameters.DerivativeCode,
                BodyId = parameters.BodyId.GetValueOrDefault(),
                EngineId = parameters.EngineId.GetValueOrDefault(),
                TransmissionId = parameters.TransmissionId.GetValueOrDefault()
            };
            importView.CurrentException = await DataContext.Import.AddDerivative(filter, derivative);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var feature = new FdpFeature()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                FeatureCode = parameters.ImportFeatureCode,
                BrandDescription = parameters.FeatureDescription,
                FeatureGroupId = parameters.FeatureGroupId
            };
            importView.CurrentException = await DataContext.Import.AddFeature(filter, feature);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingTrim(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var trim = new FdpTrim()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                Name = parameters.TrimName,
                Abbreviation = parameters.TrimAbbreviation,
                Level = parameters.TrimLevel,
                DPCK = parameters.DPCK
            };
            importView.CurrentException = await DataContext.Import.AddTrim(filter, trim);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddSpecialFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var specialFeature = new FdpSpecialFeature()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                FeatureCode = parameters.ImportFeatureCode,
                SpecialFeatureType = new FdpSpecialFeatureType()
                {
                    FdpSpecialFeatureTypeId = parameters.SpecialFeatureTypeId
                }
            };
            importView.CurrentException = await DataContext.Import.AddSpecialFeature(filter, specialFeature);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingDerivative(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);

            // As we don't have the body, engine and transmission passed in, we can pick this up from the model
            var derivative = importView.AvailableDerivatives
                .Where(d => d.DerivativeCode.Equals(parameters.DerivativeCode, StringComparison.InvariantCultureIgnoreCase))
                .First();

            var derivativeMapping = new FdpDerivativeMapping()
            {
                ImportDerivativeCode = parameters.ImportDerivativeCode,
                
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                DerivativeCode = parameters.DerivativeCode,
                BodyId = derivative.BodyId.GetValueOrDefault(),
                EngineId = derivative.EngineId.GetValueOrDefault(),
                TransmissionId = derivative.TransmissionId.GetValueOrDefault()
            };
            importView.CurrentException = await DataContext.Import.MapDerivative(filter, derivativeMapping);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var feature = importView.AvailableFeatures
                .Where(f => f.FeatureCode.Equals(parameters.FeatureCode, StringComparison.InvariantCultureIgnoreCase))
                .First();

            var featureMapping = new FdpFeatureMapping()
            {
                ImportFeatureCode = parameters.ImportFeatureCode,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                FeatureId = feature.Id
            };
            importView.CurrentException = await DataContext.Import.MapFeature(filter, featureMapping);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingTrim(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var trimMapping = new FdpTrimMapping()
            {
                ImportTrim = parameters.ImportTrim,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                TrimId = parameters.TrimId.GetValueOrDefault()
            };
            importView.CurrentException = await DataContext.Import.MapTrim(filter, trimMapping);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingMarket(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var marketMapping = new FdpMarketMapping()
            {
                ImportMarket = parameters.ImportMarket,
                MarketId = parameters.MarketId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway,
                IsGlobalMapping = parameters.IsGlobalMapping
            };
            importView.CurrentException = await DataContext.Import.MapMarket(filter, marketMapping);
            await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> IgnoreException(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);

            importView.CurrentException = await DataContext.Import.IgnoreException(filter);
            await DeactivateException(importView.CurrentException);

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
        private async Task<ImportError> DeactivateException(ImportError exception)
        {
            var filter = ImportQueueFilter.FromExceptionId(exception.FdpImportErrorId);
            filter.IsActive = false;

            return await DataContext.Import.SaveException(filter);
        }
       
        #endregion
    }
}