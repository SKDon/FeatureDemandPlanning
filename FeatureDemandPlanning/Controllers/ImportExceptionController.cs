using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Results;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportExceptionController : ControllerBase
    {
        public ImportExceptionController()
            : base()
        {
            ControllerType = ControllerType.SectionChild;
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
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

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
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var js = new JavaScriptSerializer();
            var filter = new ImportQueueFilter(parameters.ImportQueueId.Value)
            {
                ExceptionType = parameters.ExceptionType,
                FilterMessage = parameters.FilterMessage,
                Action = ImportAction.ImportQueueItem
            };
            filter.InitialiseFromJson(parameters);

            var results = await ImportViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (results.HasExceptions())
            {
                jQueryResult.TotalSuccess = results.Exceptions.TotalSuccess;
                jQueryResult.TotalFail = results.Exceptions.TotalFail;

                foreach (var result in results.Exceptions.CurrentPage)
                {
                    jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
                }
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifier);

            var importView = await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value));

            return PartialView("_ContextMenu", importView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            var importView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithActionAndProgramme);
            ValidateImportExceptionParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

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

        private string GetContentPartialViewName(ImportAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<ImportViewModel> GetModelFromParameters(ImportExceptionParameters parameters)
        {
            return await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value),
                parameters.Action);
        }
        private void ValidateImportExceptionParameters(ImportExceptionParameters parameters, string ruleSetName)
        {
            var validator = new ImportExceptionParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }

        #endregion
    }

    #region "Validation Classes"

    internal class ImportExceptionParametersValidator : AbstractValidator<ImportExceptionParameters>
    {
        public const string ExceptionIdentifier = "EXCEPTION_ID";
        public const string ExceptionIdentifierWithAction = "EXCEPTION_ID_WITH_ACTION";
        public const string ImportQueueIdentifier = "IMPORT_QUEUE_ID";
        public const string ExceptionIdentifierWithActionAndProgramme = "EXCEPTION_ID_WITH_ACTION_AND_PROGRAMME";
        public const string NoValidation = "NO_VALIDATION";

        public ImportExceptionParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(ImportQueueIdentifier, () =>
            {
                RuleFor(p => p.ImportQueueId).NotNull().WithMessage("'ImportQueueId' not specified");
            });
            RuleSet(ExceptionIdentifier, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
            });
            RuleSet(ExceptionIdentifierWithAction, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => ImportAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(ExceptionIdentifierWithActionAndProgramme, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => ImportAction.NotSet).WithMessage("'Action' not specified");
                RuleFor(p => p.ProgrammeId).NotNull().WithMessage("'ProgrammeId' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingDerivative), () =>
            {
                RuleFor(p => p.DerivativeCode).NotEmpty().WithMessage("'Derivative Code' not specified");
                RuleFor(p => p.BodyId).NotNull().WithMessage("'Body' not specified");
                RuleFor(p => p.EngineId).NotNull().WithMessage("'Engine' not specified");
                RuleFor(p => p.TransmissionId).NotNull().WithMessage("'Transmission' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingFeature), () =>
            {
                RuleFor(p => p.FeatureCode).NotEmpty().WithMessage("'Feature Code' not specified");
                RuleFor(p => p.FeatureDescription).NotNull().WithMessage("'Feature Description' not specified");
                RuleFor(p => p.FeatureGroupId).NotNull().WithMessage("'Feature Group' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingTrim), () =>
            {
                RuleFor(p => p.TrimName).NotEmpty().WithMessage("'Name' not specified");
                RuleFor(p => p.TrimAbbreviation).NotEmpty().WithMessage("'Abbreviation' not specified");
                RuleFor(p => p.TrimLevel).NotEmpty().WithMessage("'Level' not specified");
                RuleFor(p => p.DPCK).NotEmpty().WithMessage("'DPCK' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddSpecialFeature), () =>
            {
                RuleFor(p => p.FeatureCode).NotEmpty().WithMessage("'Feature Code' not specified");
                RuleFor(p => p.SpecialFeatureTypeId).NotEmpty().WithMessage("'Special Feature' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.IgnoreException), () =>
            {
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.MapMissingDerivative), () =>
            {
                RuleFor(p => p.ImportDerivativeCode).NotEmpty().WithMessage("'Import Derivative Code' not specified");
                RuleFor(p => p.DerivativeCode).NotEmpty().WithMessage("'Derivative Code' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.MapMissingFeature), () =>
            {
                RuleFor(p => p.ImportFeatureCode).NotEmpty().WithMessage("'Import Feature Code' not specified");
                RuleFor(p => p.FeatureCode).NotEmpty().WithMessage("'Feature Code' not specified");
            });
        }
    }

    #endregion
}