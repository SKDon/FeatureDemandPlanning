using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System;
using System.Threading.Tasks;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    public class DerivativeController : ControllerBase
    {
        public DerivativeController(IDataContext context)
            : base(context, ControllerType.SectionChild)
        {
        }

        [HttpGet]
        [ActionName("Index")]
        public ActionResult UserPage()
        {
            return RedirectToAction("DerivativePage");
        }
        [HttpGet]
        public async Task<ActionResult> DerivativePage(DerivativeParameters parameters)
        {
            var filter = new DerivativeFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await DerivativeViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListDerivatives(DerivativeParameters parameters)
        {
            ValidateDerivativeParameters(parameters, DerivativeParametersValidator.NoValidation);

            var filter = new DerivativeFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = DerivativeAction.Derivatives
            };
            filter.InitialiseFromJson(parameters);

            var results = await DerivativeViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Derivatives.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(DerivativeParameters parameters)
        {
            ValidateDerivativeParameters(parameters, DerivativeParametersValidator.DerivativeIdentifier);

            var filter = DerivativeFilter.FromParameters(parameters);
            filter.Action = DerivativeAction.Derivative;

            var derivativeView = await DerivativeViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(DerivativeParameters parameters)
        {
            ValidateDerivativeParameters(parameters, DerivativeParametersValidator.Action);

            var filter = DerivativeMappingFilter.FromParameters(parameters);
            var derivativeView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(DerivativeParameters parameters)
        {
            ValidateDerivativeParameters(parameters, DerivativeParametersValidator.DerivativeIdentifierWithAction);
            ValidateDerivativeParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(DerivativeParameters parameters)
        {
            var derivativeView = await GetModelFromParameters(parameters);
            if (derivativeView.Derivative is EmptyFdpDerivative)
            {
                return JsonGetFailure(string.Format("Derivative does not exist", parameters.DerivativeId));
            }

            derivativeView.Derivative = await DataContext.Vehicle.DeleteFdpDerivative(FdpDerivative.FromParameters(parameters));
            if (derivativeView.Derivative is EmptyFdpDerivative)
            {
                return JsonGetFailure(string.Format("Derivative '{0}' could not be deleted", derivativeView.Derivative.DerivativeCode));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(DerivativeAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<DerivativeViewModel> GetModelFromParameters(DerivativeParameters parameters)
        {
            return await DerivativeViewModel.GetModel(DataContext, DerivativeMappingFilter.FromParameters(parameters));
        }
        private void ValidateDerivativeParameters(DerivativeParameters parameters, string ruleSetName)
        {
            var validator = new DerivativeParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class DerivativeParametersValidator : AbstractValidator<DerivativeParameters>
    {
        public const string DerivativeIdentifier = "DERIVATIVE_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string DerivativeIdentifierWithAction = "DERIVATIVE_ID_WITH_ACTION";

        public DerivativeParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(DerivativeIdentifier, () =>
            {
                RuleFor(p => p.DerivativeId).NotNull().WithMessage("'DerivativeId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => DerivativeAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(DerivativeIdentifierWithAction, () =>
            {
                RuleFor(p => p.DerivativeId).NotNull().WithMessage("'DerivativeId' not specified");
                RuleFor(p => p.Action).NotEqual(a => DerivativeAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(DerivativeAction), DerivativeAction.Delete), () =>
            {
                RuleFor(p => p.DerivativeId).NotNull().WithMessage("'DerivativeId' not specified");
            });
        }
    }
}