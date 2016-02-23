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
    public class MarketMappingController : ControllerBase
    {
        public MarketMappingController(IDataContext context)
            : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult MarketMappingPage()
        {
            return RedirectToAction("MarketMappingPage");
        }
        [HttpGet]
        public async Task<ActionResult> MarketMappingPage(MarketMappingParameters parameters)
        {
            var filter = new MarketMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await MarketMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListMarketMappings(MarketMappingParameters parameters)
        {
            ValidateMarketMappingParameters(parameters, MarketMappingParametersValidator.NoValidation);

            var filter = new MarketMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = MarketMappingAction.Mappings
            };
            filter.InitialiseFromJson(parameters);

            var results = await MarketMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.MarketMappings.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(MarketMappingParameters parameters)
        {
            ValidateMarketMappingParameters(parameters, MarketMappingParametersValidator.MarketMappingIdentifier);

            var filter = MarketMappingFilter.FromMarketMappingParameters(parameters);
            filter.Action = MarketMappingAction.Mapping;

            var derivativeMappingView = await MarketMappingViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeMappingView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(MarketMappingParameters parameters)
        {
            ValidateMarketMappingParameters(parameters, MarketMappingParametersValidator.Action);

            var filter = MarketMappingFilter.FromMarketMappingParameters(parameters);
            var derivativeMappingView = await MarketMappingViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeMappingView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(MarketMappingParameters parameters)
        {
            ValidateMarketMappingParameters(parameters, MarketMappingParametersValidator.MarketIdentifierWithAction);
            ValidateMarketMappingParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(MarketMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure("MarketMapping does not exist");
            }

            derivativeMappingView.MarketMapping = await DataContext.Market.DeleteFdpMarketMapping(FdpMarketMapping.FromParameters(parameters));
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure(string.Format("MarketMapping '{0}' could not be deleted", derivativeMappingView.MarketMapping.ImportMarket));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Copy(MarketMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure("MarketMapping does not exist");
            }

            derivativeMappingView.MarketMapping = await DataContext.Market.CopyFdpMarketMappingToGateway(FdpMarketMapping.FromParameters(parameters), parameters.CopyToGateways);
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure(string.Format("MarketMapping '{0}' could not be copied", derivativeMappingView.MarketMapping.ImportMarket));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> CopyAll(MarketMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure("MarketMapping does not exist");
            }

            derivativeMappingView.MarketMapping = await DataContext.Market.CopyFdpMarketMappingsToGateway(FdpMarketMapping.FromParameters(parameters), parameters.CopyToGateways);
            if (derivativeMappingView.MarketMapping is EmptyFdpMarketMapping)
            {
                return JsonGetFailure(string.Format("MarketMappings could not be copied", derivativeMappingView.MarketMapping.ImportMarket));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(MarketAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<MarketMappingViewModel> GetModelFromParameters(MarketMappingParameters parameters)
        {
            return await MarketMappingViewModel.GetModel(DataContext, MarketMappingFilter.FromMarketMappingParameters(parameters));
        }
        private void ValidateMarketMappingParameters(MarketMappingParameters parameters, string ruleSetName)
        {
            var validator = new MarketMappingParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class MarketMappingParametersValidator : AbstractValidator<MarketMappingParameters>
    {
        public const string MarketMappingIdentifier = "MARKET_MAPPING_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string MarketIdentifierWithAction = "MARKET_MAPPING_ID_WITH_ACTION";

        public MarketMappingParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(MarketMappingIdentifier, () =>
            {
                RuleFor(p => p.MarketMappingId).NotNull().WithMessage("'MarketMappingId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => MarketMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(MarketIdentifierWithAction, () =>
            {
                RuleFor(p => p.MarketMappingId).NotNull().WithMessage("'MarketMappingId' not specified");
                RuleFor(p => p.Action).NotEqual(a => MarketMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(MarketMappingAction), MarketMappingAction.Delete), () =>
            {
                RuleFor(p => p.MarketMappingId).NotNull().WithMessage("'MarketMappingId' not specified");
            });
        }
    }
}