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
    public class TrimController : ControllerBase
    {
        public TrimController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult TrimPage()
        {
            return RedirectToAction("TrimPage");
        }
        [HttpGet]
        public async Task<ActionResult> TrimPage(TrimParameters parameters)
        {
            var filter = new TrimFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await TrimViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTrims(TrimParameters parameters)
        {
            ValidateTrimParameters(parameters, TrimParametersValidator.NoValidation);

            var filter = new TrimFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = TrimAction.TrimLevels
            };
            filter.InitialiseFromJson(parameters);

            var results = await TrimViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Trims.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(TrimParameters parameters)
        {
            ValidateTrimParameters(parameters, TrimParametersValidator.TrimIdentifier);

            var filter = TrimFilter.FromParameters(parameters);
            filter.Action = TrimAction.Trim;

            var derivativeView = await TrimViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(TrimParameters parameters)
        {
            ValidateTrimParameters(parameters, TrimParametersValidator.Action);

            var filter = TrimMappingFilter.FromParameters(parameters);
            var derivativeView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TrimParameters parameters)
        {
            ValidateTrimParameters(parameters, TrimParametersValidator.TrimIdentifierWithAction);
            ValidateTrimParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(TrimParameters parameters)
        {
            var derivativeView = await GetModelFromParameters(parameters);
            if (derivativeView.Trim is EmptyFdpTrim)
            {
                return JsonGetFailure(string.Format("Trim does not exist", parameters.TrimId));
            }

            derivativeView.Trim = await DataContext.Vehicle.DeleteFdpTrim(FdpTrim.FromParameters(parameters));
            if (derivativeView.Trim is EmptyFdpTrim)
            {
                return JsonGetFailure(string.Format("Trim '{0}' could not be deleted", derivativeView.Trim.Name));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(TrimAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<TrimViewModel> GetModelFromParameters(TrimParameters parameters)
        {
            return await TrimViewModel.GetModel(DataContext, TrimMappingFilter.FromParameters(parameters));
        }
        private void ValidateTrimParameters(TrimParameters parameters, string ruleSetName)
        {
            var validator = new TrimParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class TrimParametersValidator : AbstractValidator<TrimParameters>
    {
        public const string TrimIdentifier = "TRIM_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string TrimIdentifierWithAction = "TRIM_ID_WITH_ACTION";

        public TrimParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(TrimIdentifier, () =>
            {
                RuleFor(p => p.TrimId).NotNull().WithMessage("'TrimId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => TrimAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(TrimIdentifierWithAction, () =>
            {
                RuleFor(p => p.TrimId).NotNull().WithMessage("'TrimId' not specified");
                RuleFor(p => p.Action).NotEqual(a => TrimAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(TrimAction), TrimAction.Delete), () =>
            {
                RuleFor(p => p.TrimId).NotNull().WithMessage("'TrimId' not specified");
            });
        }
    }
}