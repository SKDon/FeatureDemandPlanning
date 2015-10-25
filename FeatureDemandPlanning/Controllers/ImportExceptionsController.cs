using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Models;
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
    public class ImportExceptionsController : ControllerBase
    {
        [HttpGet]
        [ActionName("ImportExceptions")]
        public async Task<ActionResult> ImportExceptionsPage(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext,
                                    new ImportQueueFilter(parameters.ImportQueueId.Value)
                                    {
                                        ExceptionType = parameters.ExceptionType,
                                        PageIndex = PageIndex,
                                        PageSize = PageSize
                                    });

            return View(importView);
        }
        [HttpPost]
        public async Task<ActionResult> ListImportExceptions(ImportExceptionParameters parameters)
        {
            JsonResult actionResult = null;
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            try
            {
                var js = new JavaScriptSerializer();
                var filter = new ImportQueueFilter(parameters.ImportQueueId.Value)
                {
                    ExceptionType = parameters.ExceptionType,
                    FilterMessage = parameters.FilterMessage
                };
                filter.InitialiseFromJson(parameters);

                var results = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
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
                actionResult = Json(jQueryResult);
            }
            catch (Exception ex)
            {
                actionResult = Json(ex);
            }
            return actionResult;
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifier);

            var importView = await ImportViewModel.GetFullAndPartialViewModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value));

            return PartialView(importView);
        }
        [HttpPost]
        public async Task<ActionResult> ModalContent(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            var importView = await ImportViewModel.GetFullAndPartialViewModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value),
                parameters.Action);

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        public ActionResult ModalAction(ImportExceptionParameters parameters)
        {
            ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters);
        }
        [HttpPost]
        public async Task<ActionResult> IgnoreException(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);

            importView.CurrentException = await DataContext.Import.Ignore(filter);
            
            return Json(importView);
        }
        #region "Private Methods"

        private string GetContentPartialViewName(ImportExceptionAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
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

    internal class ImportExceptionParametersValidator : AbstractValidator<ImportExceptionParameters>
    {
        public const string ExceptionIdentifier = "EXCEPTION_ID";
        public const string ExceptionIdentifierWithAction = "EXCEPTION_ID_WITH_ACTION";
        public const string ImportQueueIdentifier = "IMPORT_QUEUE_ID";

        public ImportExceptionParametersValidator()
        {
            RuleSet(ImportQueueIdentifier, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ImportQueueId' not specified");
            });
            RuleSet(ExceptionIdentifier, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
            });
            RuleSet(ExceptionIdentifierWithAction, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => ImportExceptionAction.NotSet).WithMessage("'Action' not specified");
            });
        }
    }
}