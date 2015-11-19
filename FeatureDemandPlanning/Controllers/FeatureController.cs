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
    public class FeatureController : ControllerBase
    {
        public FeatureController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult FeaturePage()
        {
            return RedirectToAction("FeaturePage");
        }
        [HttpGet]
        public async Task<ActionResult> FeaturePage(FeatureParameters parameters)
        {
            var filter = new FeatureFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await FeatureViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListFeatures(FeatureParameters parameters)
        {
            ValidateFeatureParameters(parameters, FeatureParametersValidator.NoValidation);

            var filter = new FeatureFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = FeatureAction.Features
            };
            filter.InitialiseFromJson(parameters);

            var results = await FeatureViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Features.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(FeatureParameters parameters)
        {
            ValidateFeatureParameters(parameters, FeatureParametersValidator.FeatureIdentifier);

            var filter = FeatureFilter.FromParameters(parameters);
            filter.Action = FeatureAction.Feature;

            var derivativeView = await FeatureViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(FeatureParameters parameters)
        {
            ValidateFeatureParameters(parameters, FeatureParametersValidator.Action);

            var filter = FeatureMappingFilter.FromParameters(parameters);
            var derivativeView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(FeatureParameters parameters)
        {
            ValidateFeatureParameters(parameters, FeatureParametersValidator.FeatureIdentifierWithAction);
            ValidateFeatureParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(FeatureParameters parameters)
        {
            var derivativeView = await GetModelFromParameters(parameters);
            if (derivativeView.Feature is EmptyFdpFeature)
            {
                return JsonGetFailure(string.Format("Feature does not exist", parameters.FeatureId));
            }

            derivativeView.Feature = await DataContext.Vehicle.DeleteFdpFeature(FdpFeature.FromParameters(parameters));
            if (derivativeView.Feature is EmptyFdpFeature)
            {
                return JsonGetFailure(string.Format("Feature '{0}' could not be deleted", derivativeView.Feature.FeatureCode));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(FeatureAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<FeatureViewModel> GetModelFromParameters(FeatureParameters parameters)
        {
            return await FeatureViewModel.GetModel(DataContext, FeatureMappingFilter.FromParameters(parameters));
        }
        private void ValidateFeatureParameters(FeatureParameters parameters, string ruleSetName)
        {
            var validator = new FeatureParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class FeatureParametersValidator : AbstractValidator<FeatureParameters>
    {
        public const string FeatureIdentifier = "FEATURE_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string FeatureIdentifierWithAction = "FEATURE_ID_WITH_ACTION";

        public FeatureParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(FeatureIdentifier, () =>
            {
                RuleFor(p => p.FeatureId).NotNull().WithMessage("'FeatureId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => FeatureAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(FeatureIdentifierWithAction, () =>
            {
                RuleFor(p => p.FeatureId).NotNull().WithMessage("'FeatureId' not specified");
                RuleFor(p => p.Action).NotEqual(a => FeatureAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(FeatureAction), FeatureAction.Delete), () =>
            {
                RuleFor(p => p.FeatureId).NotNull().WithMessage("'FeatureId' not specified");
            });
        }
    }
}