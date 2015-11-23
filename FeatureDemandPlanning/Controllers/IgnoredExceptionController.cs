using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class IgnoredExceptionController : ControllerBase
    {
        public IgnoredExceptionController()
            : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult IgnoredExceptionPage()
        {
            return RedirectToAction("IgnoredExceptionPage");
        }
        [HttpGet]
        public async Task<ActionResult> IgnoredExceptionPage(IgnoredExceptionParameters parameters)
        {
            var filter = new IgnoredExceptionFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await IgnoredExceptionViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListIgnoredExceptions(IgnoredExceptionParameters parameters)
        {
            ValidateIgnoredExceptionParameters(parameters, IgnoredExceptionParametersValidator.NoValidation);

            var filter = new IgnoredExceptionFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = IgnoredExceptionAction.Exceptions
            };
            filter.InitialiseFromJson(parameters);

            var results = await IgnoredExceptionViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.IgnoredExceptions.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(IgnoredExceptionParameters parameters)
        {
            ValidateIgnoredExceptionParameters(parameters, IgnoredExceptionParametersValidator.IgnoredExceptionIdentifier);

            var filter = IgnoredExceptionFilter.FromParameters(parameters);
            filter.Action = IgnoredExceptionAction.Exception;

            var ignoredExceptionView = await IgnoredExceptionViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", ignoredExceptionView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(IgnoredExceptionParameters parameters)
        {
            ValidateIgnoredExceptionParameters(parameters, IgnoredExceptionParametersValidator.Action);

            var filter = IgnoredExceptionFilter.FromParameters(parameters);
            var ignoredExceptionView = await IgnoredExceptionViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), ignoredExceptionView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(IgnoredExceptionParameters parameters)
        {
            ValidateIgnoredExceptionParameters(parameters, IgnoredExceptionParametersValidator.IgnoredExceptionIdentifierWithAction);
            ValidateIgnoredExceptionParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(IgnoredExceptionParameters parameters)
        {
            var ignoredExceptionView = await GetModelFromParameters(parameters);
            if (ignoredExceptionView.IgnoredException is EmptyFdpImportErrorExclusion)
            {
                return JsonGetFailure("IgnoredException does not exist");
            }

            ignoredExceptionView.IgnoredException = await DataContext.Import.DeleteFdpImportErrorExclusion(FdpImportErrorExclusion.FromParameters(parameters));
            if (ignoredExceptionView.IgnoredException is EmptyFdpImportErrorExclusion)
            {
                return JsonGetFailure("IgnoredException could not be deleted");
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(IgnoredExceptionAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<IgnoredExceptionViewModel> GetModelFromParameters(IgnoredExceptionParameters parameters)
        {
            return await IgnoredExceptionViewModel.GetModel(DataContext, IgnoredExceptionFilter.FromParameters(parameters));
        }
        private void ValidateIgnoredExceptionParameters(IgnoredExceptionParameters parameters, string ruleSetName)
        {
            var validator = new IgnoredExceptionParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class IgnoredExceptionParametersValidator : AbstractValidator<IgnoredExceptionParameters>
    {
        public const string IgnoredExceptionIdentifier = "IGNORED_EXCEPTION_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string IgnoredExceptionIdentifierWithAction = "IGNORED_EXCEPTION_ID_WITH_ACTION";

        public IgnoredExceptionParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(IgnoredExceptionIdentifier, () =>
            {
                RuleFor(p => p.IgnoredExceptionId).NotNull().WithMessage("'IgnoredExceptionId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => IgnoredExceptionAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(IgnoredExceptionIdentifierWithAction, () =>
            {
                RuleFor(p => p.IgnoredExceptionId).NotNull().WithMessage("'IgnoredExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => IgnoredExceptionAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(IgnoredExceptionAction), IgnoredExceptionAction.Delete), () =>
            {
                RuleFor(p => p.IgnoredExceptionId).NotNull().WithMessage("'IgnoredExceptionId' not specified");
            });
        }
    }
}