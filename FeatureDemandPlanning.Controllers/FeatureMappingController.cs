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
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Controllers
{
    public class FeatureMappingController : ControllerBase
    {
        public FeatureMappingController(IDataContext context)
            : base(context, ControllerType.SectionChild)
        {
        }

        [HttpGet]
        [ActionName("Index")]
        public ActionResult FeatureMappingPage()
        {
            return RedirectToAction("FeatureMappingPage");
        }
        [HttpGet]
        public async Task<ActionResult> FeatureMappingPage(FeatureMappingParameters parameters)
        {
            var filter = new FeatureMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await FeatureMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpGet]
        public async Task<ActionResult> FeatureCodePage(FeatureMappingParameters parameters)
        {
            var filter = new FeatureMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await FeatureMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListFeatureMappings(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.NoValidation);

            var filter = new FeatureMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = FeatureMappingAction.Mappings
            };
            filter.InitialiseFromJson(parameters);

            var results = await FeatureMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.FeatureMappings.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListFeatureCodes(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.NoValidation);

            var filter = new FeatureMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = FeatureMappingAction.FeatureCodes
            };
            filter.InitialiseFromJson(parameters);

            var results = await FeatureMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.OxoFeatures.CurrentPage)
            {
                try
                {
                    jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                }

            }
            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> UpdateFeatureCode(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.UpdateFeatureCode);

            await DataContext.Vehicle.UpdateFeatureCode(OxoFeature.FromParameters(parameters));

            return JsonGetSuccess();
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.FeatureMappingIdentifier);

            var filter = FeatureMappingFilter.FromFeatureMappingParameters(parameters);
            filter.Action = FeatureMappingAction.Mapping;

            var derivativeMappingView = await FeatureMappingViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeMappingView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.Action);

            var filter = FeatureMappingFilter.FromFeatureMappingParameters(parameters);
            var derivativeMappingView = await FeatureMappingViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeMappingView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(FeatureMappingParameters parameters)
        {
            ValidateFeatureMappingParameters(parameters, FeatureMappingParametersValidator.FeatureIdentifierWithAction);
            ValidateFeatureMappingParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            if (parameters.Action == FeatureMappingAction.CopyAll || parameters.Action == FeatureMappingAction.Copy)
            {
                TempData["CopyToGateways"] = parameters.CopyToGateways;
            }

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(FeatureMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.FeatureMapping is EmptyFdpFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            derivativeMappingView.FeatureMapping = await DataContext.Vehicle.DeleteFdpFeatureMapping(FdpFeatureMapping.FromParameters(parameters));
            if (derivativeMappingView.FeatureMapping is EmptyFdpFeatureMapping)
            {
                return JsonGetFailure(string.Format("FeatureMapping '{0}' could not be deleted", derivativeMappingView.FeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Copy(FeatureMappingParameters parameters)
        {
            parameters.CopyToGateways = (IEnumerable<string>)TempData["CopyToGateways"];
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.FeatureMapping is EmptyFdpFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            derivativeMappingView.FeatureMapping = await DataContext.Vehicle.CopyFdpFeatureMappingToDocument(FdpFeatureMapping.FromParameters(parameters), parameters.TargetDocumentId.GetValueOrDefault());
            if (derivativeMappingView.FeatureMapping is EmptyFdpFeatureMapping)
            {
                return JsonGetFailure(string.Format("FeatureMapping '{0}' could not be copied", derivativeMappingView.FeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> CopyAll(FeatureMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.FeatureMapping is EmptyFdpFeatureMapping)
            {
                return JsonGetFailure("FeatureMapping does not exist");
            }

            var results = await DataContext.Vehicle.CopyFdpFeatureMappingsToDocument(parameters.DocumentId.GetValueOrDefault(), parameters.TargetDocumentId.GetValueOrDefault());
            if (results == null || !results.Any())
            {
                return JsonGetFailure(string.Format("FeatureMappings could not be copied", derivativeMappingView.FeatureMapping.ImportFeatureCode));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(FeatureAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<FeatureMappingViewModel> GetModelFromParameters(FeatureMappingParameters parameters)
        {
            return await FeatureMappingViewModel.GetModel(DataContext, FeatureMappingFilter.FromFeatureMappingParameters(parameters));
        }
        private void ValidateFeatureMappingParameters(FeatureMappingParameters parameters, string ruleSetName)
        {
            var validator = new FeatureMappingParametersValidator(DataContext);
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class FeatureMappingParametersValidator : AbstractValidator<FeatureMappingParameters>
    {
        public const string FeatureMappingIdentifier = "FEATURE_MAPPING_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string FeatureIdentifierWithAction = "FEATURE_ID_WITH_ACTION";
        public const string UpdateFeatureCode = "UPDATE_FEATURE_CODE";

        public FeatureMappingParametersValidator(IDataContext context)
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(FeatureMappingIdentifier, () =>
            {
                RuleFor(p => p.FeatureMappingId).NotNull().WithMessage("'FeatureMappingId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => FeatureMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(FeatureIdentifierWithAction, () =>
            {
                RuleFor(p => p.FeatureMappingId).NotNull().WithMessage("'FeatureMappingId' not specified");
                RuleFor(p => p.Action).NotEqual(a => FeatureMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(FeatureMappingAction), FeatureMappingAction.Delete), () =>
            {
                RuleFor(p => p.FeatureMappingId).NotNull().WithMessage("'FeatureMappingId' not specified");
            });
            RuleSet(UpdateFeatureCode, () =>
            {
                RuleFor(p => p.DocumentId).NotNull().WithMessage("'Document Id' not defined");
                RuleFor(p => p.FeatureId).NotNull().WithMessage("'Feature Id' not defined");
                RuleFor(p => p).SetValidator(new FeatureCodeUniqueValidator(context));
            });
        }
    }
}