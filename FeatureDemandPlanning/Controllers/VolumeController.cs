using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System.Linq;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using System.Web.Script.Serialization;
using MvcSiteMapProvider.Web.Mvc.Filters;
using System;
using FeatureDemandPlanning.Model.Results;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling viewing / editing and updating of volume (take rate information)
    /// </summary>
    public class VolumeController : ControllerBase
    {
        #region "Constructors"

        public VolumeController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }

        #endregion

        #region "Public Properties"

        public PageFilter PageFilter { get { return _pageFilter; } }

        #endregion

        [HttpGet]
        [ActionName("Index")]
        public ActionResult TakeRatePage()
        {
            return RedirectToAction("TakeRatePage", new TakeRateParameters());
        }
        [HttpGet]
        public async Task<ActionResult> TakeRatePage(TakeRateParameters parameters)
        {
            ValidateTakeRateParameters(parameters, TakeRateParametersValidator.NoValidation);

            var takeRateView = await TakeRateViewModel.GetModel(DataContext, new TakeRateFilter());

            return View(takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTakeRateData(TakeRateParameters parameters)
        {
            ValidateTakeRateParameters(parameters, TakeRateParametersValidator.NoValidation);

            var js = new JavaScriptSerializer();
            var filter = new TakeRateFilter()
            {
                FilterMessage = parameters.FilterMessage,
                TakeRateStatusId = parameters.TakeRateStatusId
            };
            filter.InitialiseFromJson(parameters);

            var results = await TakeRateViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.TakeRates.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                TakeRateFilter.FromTakeRateId(parameters.TakeRateId.GetValueOrDefault()));

            return PartialView("_ContextMenu", takeRateView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), takeRateView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifier);
            TakeRateParametersValidator
                .ValidateTakeRateParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> Save(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
               .ValidateTakeRateParameters(parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var filter = TakeRateFilter.FromTakeRateId(parameters.TakeRateId.Value);
            var results = await DataContext.Volume.SaveChangeset(parameters);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult Validate(Volume volumeToValidate,
                                     VolumeValidationSection sectionToValidate = VolumeValidationSection.All)
        {
            var volumeModel = FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volumeToValidate, PageFilter).Result;
            var validator = new VolumeValidator(volumeModel.Volume);
            var ruleSets = VolumeValidator.GetRulesetsToValidate(sectionToValidate);
            var jsonResult = new JsonResult()
            {
                Data = new { IsValid = true }
            };

            var results = validator.Validate(volumeModel.Volume, ruleSet: ruleSets);
            if (results.IsValid) return jsonResult;
            var errorModel = results.Errors
                .Select(e => new ValidationError(new ValidationErrorItem
                {
                    ErrorMessage = e.ErrorMessage,
                    CustomState = e.CustomState
                })
                {
                    key = e.PropertyName
                });

            jsonResult = new JsonResult()
            {
                Data = new ValidationMessage(false, errorModel)
            };
            return jsonResult;
        }
        public ActionResult ValidationMessage(ValidationMessage message)
        {
            // Something is making a GET request to this page and I can't figure out what
            return PartialView("_ValidationMessage", message);
        }
        [HttpGet]
        [SiteMapTitle("DocumentName")]
        public ActionResult Document(int? oxoDocId,
                                     int? marketGroupId,
                                     int? marketId,
                                     TakeRateResultMode resultsMode = TakeRateResultMode.PercentageTakeRate)
        {
            ViewBag.PageTitle = "OXO Volume";

            var filter = new VolumeFilter()
            {
                OxoDocId = oxoDocId,
                MarketGroupId = marketGroupId,
                MarketId = marketId,
                Mode = resultsMode,
            };
            var model = FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, filter, PageFilter).Result;

            ViewData["DocumentName"] = model.Volume.Document.Name;

            return View("Document", model);
        }

        #region "Private Methods"

        private async Task<FdpOxoVolumeViewModel> GetModelFromParameters(TakeRateParameters parameters)
        {
            return await FdpOxoVolumeViewModel.GetModel(
                DataContext,
                TakeRateFilter.FromTakeRateId(parameters.TakeRateId.Value),
                parameters.Action);
        }
        private void ProcessVolumeData(IVolume volume)
        {
            DataContext.Volume.SaveVolume(volume);
            DataContext.Volume.ProcessMappedData(volume);
        }
        private static void ValidateTakeRateParameters(TakeRateParameters parameters, string ruleSetName)
        {
            var validator = new TakeRateParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }

        #endregion

        #region "Private Members"

        private PageFilter _pageFilter = new PageFilter();

        #endregion
    }

    internal class TakeRateParametersValidator : AbstractValidator<TakeRateParameters>
    {
        public const string TakeRateIdentifier = "TAKE_RATE_ID";
        public const string TakeRateIdentifierWithChangeset = "TAKE_RATE_ID_WITH_CHANGESET";
        public const string NoValidation = "NO_VALIDATION";

        public TakeRateParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(TakeRateIdentifier, () =>
            {
                RuleFor(p => p.TakeRateId).NotNull().WithMessage("'DocumentId' not specified");
            });
            RuleSet(TakeRateIdentifierWithChangeset, () =>
            {
                RuleFor(p => p.TakeRateId).NotNull().WithMessage("'DocumentId' not specified");
                RuleFor(p => p.Changes).Must(NotBeAnEmptyChangeset).WithMessage("No changes to save");
            });
        }
        public static bool NotBeAnEmptyChangeset(IEnumerable<DataChange> changeSet)
        {
            return changeSet != null && changeSet.Any();
        }
        public static TakeRateParametersValidator ValidateTakeRateParameters(TakeRateParameters parameters, string ruleSetName)
        {
            var validator = new TakeRateParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
            return validator;
        }
    }
}