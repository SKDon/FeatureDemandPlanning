using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.BusinessObjects.Validators;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Models;
using FluentValidation;
using FluentValidation.Internal;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling viewing / editing and updating of volume (take rate information)
    /// </summary>
    [System.Runtime.InteropServices.GuidAttribute("F9C8183E-8411-4528-A4A6-E9B7AD75CA0B")]
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

        [HttpPost]
        public ActionResult VolumePage(Volume volume, int pageIndex)
        {
            PageFilter.PageIndex = pageIndex;
         
            var model = FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, volume, PageFilter);
            var view = string.Empty;

            switch ((VolumePage)pageIndex)
            {
                case FeatureDemandPlanning.Enumerations.VolumePage.Vehicle:
                    view = "_Vehicle";
                    break;
                case FeatureDemandPlanning.Enumerations.VolumePage.ImportedData:
                    view = "_ImportedData";
                    break;
                case FeatureDemandPlanning.Enumerations.VolumePage.OxoDocument:
                    view = "_OXODocuments";
                    break;
                case FeatureDemandPlanning.Enumerations.VolumePage.Confirm:
                    view = "_Confirm";
                    break;
                case FeatureDemandPlanning.Enumerations.VolumePage.VolumeData:
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
                                     VolumeResultMode resultsMode = VolumeResultMode.Raw)
        {
            ViewBag.PageTitle = "OXO Volume";

            var filter = new VolumeFilter()
            {
                OxoDocId = oxoDocId,
                MarketGroupId = marketGroupId,
                MarketId = marketId,
                Mode = resultsMode,
            };
            return View("Volume", FdpOxoVolumeViewModel.GetFullAndPartialViewModel(DataContext, filter, PageFilter));
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

        #endregion

        #region "Private Members"

        private PageFilter _pageFilter = new PageFilter();

        #endregion
    }
}