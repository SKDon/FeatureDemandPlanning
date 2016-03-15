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
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    public class SpecialFeatureMappingController : ControllerBase
    {
        public SpecialFeatureMappingController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult SpecialFeatureMappingPage()
        {
            return RedirectToAction("SpecialFeatureMappingPage");
        }
        [HttpGet]
        public async Task<ActionResult> SpecialFeatureMappingPage(SpecialFeatureMappingParameters parameters)
        {
            var filter = new SpecialFeatureMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await SpecialFeatureMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListSpecialFeatureMappings(SpecialFeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, SpecialFeatureMappingParametersValidator.NoValidation);

            var filter = new SpecialFeatureMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = SpecialFeatureMappingAction.Mappings
            };
            filter.InitialiseFromJson(parameters);

            var results = await SpecialFeatureMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.SpecialFeatureMappings.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(SpecialFeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, SpecialFeatureMappingParametersValidator.SpecialFeatureMappingIdentifier);

            var filter = SpecialFeatureMappingFilter.FromFeatureMappingParameters(parameters);
            filter.Action = SpecialFeatureMappingAction.Mapping;

            var derivativeMappingView = await SpecialFeatureMappingViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeMappingView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(SpecialFeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, SpecialFeatureMappingParametersValidator.Action);

            var filter = SpecialFeatureMappingFilter.FromFeatureMappingParameters(parameters);
            var derivativeMappingView = await SpecialFeatureMappingViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeMappingView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(SpecialFeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, SpecialFeatureMappingParametersValidator.SpecialFeatureIdentifierWithAction);
            ValidateFeatureMappingParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            if (parameters.Action == SpecialFeatureMappingAction.CopyAll || parameters.Action == SpecialFeatureMappingAction.Copy)
            {
                TempData["CopyToGateways"] = parameters.CopyToGateways;
            }

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(SpecialFeatureMappingParameters parameters)
        {
            var specialFeatureMappingView = await GetModelFromParameters(parameters);
            if (specialFeatureMappingView.SpecialFeatureMapping is EmptyFdpSpecialFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            specialFeatureMappingView.SpecialFeatureMapping = await DataContext.Vehicle.DeleteFdpSpecialFeatureMapping(FdpSpecialFeatureMapping.FromParameters(parameters));
            if (specialFeatureMappingView.SpecialFeatureMapping is EmptyFdpSpecialFeatureMapping)
            {
                return JsonGetFailure(string.Format("FeatureMapping '{0}' could not be deleted", specialFeatureMappingView.SpecialFeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Copy(SpecialFeatureMappingParameters parameters)
        {
            parameters.CopyToGateways = (IEnumerable<string>)TempData["CopyToGateways"];
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.SpecialFeatureMapping is EmptyFdpSpecialFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            derivativeMappingView.SpecialFeatureMapping = await DataContext.Vehicle.CopyFdpSpecialFeatureMappingToDocument(FdpSpecialFeatureMapping.FromParameters(parameters), parameters.DocumentId.GetValueOrDefault());
            if (derivativeMappingView.SpecialFeatureMapping is EmptyFdpSpecialFeatureMapping)
            {
                return JsonGetFailure(string.Format("FeatureMapping '{0}' could not be copied", derivativeMappingView.SpecialFeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> CopyAll(SpecialFeatureMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.SpecialFeatureMapping is EmptyFdpSpecialFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            var results = await DataContext.Vehicle.CopyFdpSpecialFeatureMappingsToDocument(parameters.DocumentId.GetValueOrDefault(), parameters.TargetDocumentId.GetValueOrDefault());
            if (results == null || ! results.Any())
            {
                return JsonGetFailure(string.Format("FeatureMappings could not be copied", derivativeMappingView.SpecialFeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(FeatureAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<SpecialFeatureMappingViewModel> GetModelFromParameters(SpecialFeatureMappingParameters parameters)
        {
            return await SpecialFeatureMappingViewModel.GetModel(DataContext, SpecialFeatureMappingFilter.FromFeatureMappingParameters(parameters));
        }
        private void ValidateFeatureMappingParameters(SpecialFeatureMappingParameters parameters, string ruleSetName)
        {
            var validator = new SpecialFeatureMappingParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class SpecialFeatureMappingParametersValidator : AbstractValidator<SpecialFeatureMappingParameters>
    {
        public const string SpecialFeatureMappingIdentifier = "SPECIAL_FEATURE_MAPPING_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string SpecialFeatureIdentifierWithAction = "SPECIAL_FEATURE_MAPPING_ID_WITH_ACTION";

        public SpecialFeatureMappingParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(SpecialFeatureMappingIdentifier, () =>
            {
                RuleFor(p => p.SpecialFeatureMappingId).NotNull().WithMessage("'SpecialFeatureMappingId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => SpecialFeatureMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(SpecialFeatureIdentifierWithAction, () =>
            {
                RuleFor(p => p.SpecialFeatureMappingId).NotNull().WithMessage("'SpecialFeatureMappingId' not specified");
                RuleFor(p => p.Action).NotEqual(a => SpecialFeatureMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(SpecialFeatureMappingAction), SpecialFeatureMappingAction.Delete), () =>
            {
                RuleFor(p => p.SpecialFeatureMappingId).NotNull().WithMessage("'SpecialFeatureMappingId' not specified");
            });
            RuleSet(Enum.GetName(typeof(SpecialFeatureMappingAction), SpecialFeatureMappingAction.Copy), () =>
            {
                RuleFor(p => p.SpecialFeatureMappingId).NotNull().WithMessage("'SpecialFeatureMappingId' not specified");
                RuleFor(p => p.CopyToGateways).Must(HaveCopyToGateways).WithMessage("'CopyToGateways' cannot be empty");
            });
        }
        public bool HaveCopyToGateways(IEnumerable<string> copyToGateways)
        {
            return copyToGateways != null && copyToGateways.Any();
        }
    }
}