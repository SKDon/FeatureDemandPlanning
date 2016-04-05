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
    public class TrimMappingController : ControllerBase
    {
        public TrimMappingController(IDataContext context)
            : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult TrimMappingPage()
        {
            return RedirectToAction("TrimMappingPage");
        }
        [HttpGet]
        public async Task<ActionResult> TrimMappingPage(TrimMappingParameters parameters)
        {
            var filter = new TrimMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await TrimMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpGet]
        public async Task<ActionResult> DPCKPage(TrimMappingParameters parameters)
        {
            var filter = new TrimMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await TrimMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTrimMappings(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.NoValidation);

            var filter = new TrimMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = TrimMappingAction.Mappings
            };
            filter.InitialiseFromJson(parameters);

            var results = await TrimMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.TrimMappings.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListDpckCodes(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.NoValidation);

            var filter = new TrimMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = TrimMappingAction.DPCKCodes,
                DocumentId = parameters.DocumentId
            };
            filter.InitialiseFromJson(parameters);

            var results = await TrimMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.OxoTrim.CurrentPage)
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
        public async Task<ActionResult> UpdateDpckCode(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.UpdateDpckCode);

            await DataContext.Vehicle.UpdateDpckCode(OxoTrim.FromParameters(parameters));

            return JsonGetSuccess();
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.TrimMappingIdentifier);

            var filter = TrimMappingFilter.FromTrimMappingParameters(parameters);
            filter.Action = TrimMappingAction.Mapping;

            var derivativeMappingView = await TrimMappingViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeMappingView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.Action);

            var filter = TrimMappingFilter.FromTrimMappingParameters(parameters);
            var derivativeMappingView = await TrimMappingViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeMappingView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TrimMappingParameters parameters)
        {
            ValidateTrimMappingParameters(parameters, TrimMappingParametersValidator.TrimIdentifierWithAction);
            ValidateTrimMappingParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));
            //if (parameters.Action == TrimMappingAction.CopyAll || parameters.Action == TrimMappingAction.Copy)
            //{
            //    TempData["CopyToGateways"] = parameters.CopyToGateways;
            //}

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(TrimMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.TrimMapping is EmptyFdpTrimMapping)
            {
                return JsonGetFailure("TrimMapping does not exist");
            }

            derivativeMappingView.TrimMapping = await DataContext.Vehicle.DeleteFdpTrimMapping(FdpTrimMapping.FromParameters(parameters));
            //if (derivativeMappingView.TrimMapping is EmptyFdpTrimMapping)
            //{
            //    return JsonGetFailure(string.Format("TrimMapping '{0}' could not be deleted", derivativeMappingView.TrimMapping.ImportTrim));
            //}

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Copy(TrimMappingParameters parameters)
        {
            //parameters.CopyToGateways = (IEnumerable<string>)TempData["CopyToGateways"];
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.TrimMapping is EmptyFdpTrimMapping)
            {
                return JsonGetFailure("TrimMapping does not exist");
            }

            derivativeMappingView.TrimMapping = await DataContext.Vehicle.CopyFdpTrimMappingToDocument(FdpTrimMapping.FromParameters(parameters), parameters.TargetDocumentId.GetValueOrDefault());
            if (derivativeMappingView.TrimMapping is EmptyFdpTrimMapping)
            {
                return JsonGetFailure(string.Format("TrimMapping '{0}' could not be copied", derivativeMappingView.TrimMapping.ImportTrim));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> CopyAll(TrimMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.TrimMapping is EmptyFdpTrimMapping)
            {
                return JsonGetFailure("TrimMapping does not exist");
            }

            var results = await DataContext.Vehicle.CopyFdpTrimMappingsToDocument(parameters.DocumentId.GetValueOrDefault(), parameters.TargetDocumentId.GetValueOrDefault());
            if (results == null || !results.Any())
            {
                return JsonGetFailure(string.Format("TrimMappings could not be copied", derivativeMappingView.TrimMapping.ImportTrim));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(TrimAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<TrimMappingViewModel> GetModelFromParameters(TrimMappingParameters parameters)
        {
            return await TrimMappingViewModel.GetModel(DataContext, TrimMappingFilter.FromTrimMappingParameters(parameters));
        }
        private void ValidateTrimMappingParameters(TrimMappingParameters parameters, string ruleSetName)
        {
            var validator = new TrimMappingParametersValidator(DataContext);
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class TrimMappingParametersValidator : AbstractValidator<TrimMappingParameters>
    {
        public const string TrimMappingIdentifier = "TRIM_MAPPING_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string TrimIdentifierWithAction = "TRIM_ID_WITH_ACTION";
        public const string UpdateDpckCode = "UPDATE_DPCK";

        public TrimMappingParametersValidator(IDataContext context)
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(TrimMappingIdentifier, () =>
            {
                RuleFor(p => p.TrimMappingId).NotNull().WithMessage("'TrimMappingId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => TrimMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(TrimIdentifierWithAction, () =>
            {
                RuleFor(p => p.TrimMappingId).NotNull().WithMessage("'TrimMappingId' not specified");
                RuleFor(p => p.Action).NotEqual(a => TrimMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(TrimMappingAction), TrimMappingAction.Delete), () =>
            {
                RuleFor(p => p.TrimMappingId).NotNull().WithMessage("'TrimMappingId' not specified");
            });
            RuleSet(UpdateDpckCode, () =>
            {
                RuleFor(p => p.TrimId).NotNull().WithMessage("'TrimId' not specified");
                RuleFor(p => p).SetValidator(new DpckUniqueValidator(context));
            });
        }
    }
}