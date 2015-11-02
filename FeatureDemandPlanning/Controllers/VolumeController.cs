using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using FluentValidation.Internal;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;

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
        public ActionResult VolumePage(Volume volume, int pageIndex)
        {
            PageFilter.PageIndex = pageIndex;
         
            var model = FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volume, PageFilter);
            var view = string.Empty;

            switch ((VolumePage)pageIndex)
            {
                case FeatureDemandPlanning.Model.Enumerations.VolumePage.Vehicle:
                    view = "_Vehicle";
                    break;
                case FeatureDemandPlanning.Model.Enumerations.VolumePage.ImportedData:
                    view = "_ImportedData";
                    break;
                case FeatureDemandPlanning.Model.Enumerations.VolumePage.OxoDocument:
                    view = "_OXODocuments";
                    break;
                case FeatureDemandPlanning.Model.Enumerations.VolumePage.Confirm:
                    view = "_Confirm";
                    break;
                case FeatureDemandPlanning.Model.Enumerations.VolumePage.VolumeData:
                    view = "_VolumeData";
                    ProcessVolumeData(model.Volume);
                    break;
                default:
                    view = "_OXODocuments";
                    break;
            }
            return PartialView(view, model);
        }

        [HttpPost]
        public ActionResult Validate(Volume volumeToValidate,
                                     VolumeValidationSection sectionToValidate = VolumeValidationSection.All)
        {
            var volumeModel = FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volumeToValidate, PageFilter);
            var validator = new VolumeValidator(volumeModel.Volume);
            var ruleSets = VolumeValidator.GetRulesetsToValidate(sectionToValidate);
            var jsonResult = new JsonResult()
            {
                Data = new { IsValid = true }
            };

            var results = validator.Validate(volumeModel.Volume, ruleSet: ruleSets);
            if (!results.IsValid)
            {
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
            }
            return jsonResult;
        }

        public ActionResult ValidationMessage(ValidationMessage message)
        {
            // Something is making a GET request to this page and I can't figure out what
            return PartialView("_ValidationMessage", message);
        }

        [HttpGet]
        public ActionResult Document(int? oxoDocId, 
                                     int? marketGroupId, 
                                     int? marketId,
                                     TakeRateResultMode resultsMode = TakeRateResultMode.Raw)
        {
            ViewBag.PageTitle = "OXO Volume";

            var filter = new VolumeFilter()
            {
                OxoDocId = oxoDocId,
                MarketGroupId = marketGroupId,
                MarketId = marketId,
                Mode = resultsMode,
            };
            return View("Document", FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, filter, PageFilter));
        }

        [HttpPost]
        public ActionResult OxoDocuments(Volume volume)
        {
            return PartialView("_OxoDocuments", FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volume, PageFilter));
        }

        [HttpPost]
        public ActionResult AvailableImports(Volume volume)
        {
            return PartialView("_ImportedData", FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volume, PageFilter));
        }

        #region "Private Methods"

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
        public const string NoValidation = "NO_VALIDATION";

        public TakeRateParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(TakeRateIdentifier, () =>
            {
                RuleFor(p => p.TakeRateId).NotNull().WithMessage("'TakeRateId' not specified");
            });
        }
    }
}