using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using System.Linq;
using System.Web.Mvc;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.IO.Compression;
using System.Reflection;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling viewing / editing and updating of take rate information
    /// </summary>
    public class TakeRateDataController : ControllerBase
    {
        #region "Constructors"

        public TakeRateDataController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }

        #endregion

        [HttpGet]
        [ActionName("Index")]
        //[OutputCache(Duration = 600, 
        //    VaryByParam = "TakeRateParameters.TakeRateId,TakeRateParameters.MarketId,TakeRateParameters.PageSize,TakeRateParameters.PageIndex")]
        //[SiteMapTitle("DocumentName")]
        public ActionResult TakeRateDataPage(TakeRateParameters parameters)
        {
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = TakeRateViewModel.GetModel(DataContext, filter).Result;

            var title = string.Format("{0} - {1} ({2}) - {3}", 
                model.Document.Vehicle.Code,
                model.Document.Vehicle.ModelYear, model.Document.UnderlyingOxoDocument.Gateway,
                model.Document.TakeRateSummary.First().Version);
            
            ViewBag.Title = title;

            string displayName;
            if (model.Document.Market is EmptyMarket)
            {
                displayName = string.Format("{0} - ALL MARKETS", title);
            }
            else
            {
                displayName = string.Format("{0} - {1}",
                    title,
                    model.Document.Market.Name.ToUpper());
            }

            ViewData["DocumentName"] = displayName;

            return View("TakeRateDataPage", model);
        }

        [HttpPost]
        public async Task<JsonResult> TakeRateFeatureData(TakeRateParameters parameters)
        {
            Log.Debug(MethodBase.GetCurrentMethod().Name);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = await TakeRateViewModel.GetModel(DataContext, filter);

            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in model.Document.TakeRateData.RawData.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in model.Document.TakeRateData.RawData.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }

            Response.AddHeader("Content-Encoding", "gzip");
            Response.Filter = new GZipStream(Response.Filter,
                                 CompressionMode.Compress);
            
            return Json(new
            {
                FeatureData = rows,
                model.Document.Market
            });
        }

        [HttpPost]
        public async Task<JsonResult> TakeRateModelData(TakeRateParameters parameters)
        {
            Log.Debug(MethodBase.GetCurrentMethod().Name);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = await TakeRateViewModel.GetModel(DataContext, filter);

            Response.AddHeader("Content-Encoding", "gzip");
            Response.Filter = new GZipStream(Response.Filter,
                                 CompressionMode.Compress);

            return Json(new
            {
                ModelData = model.Document.TakeRateData.TakeRateSummaryByModel,
                model.Document.Market
            });
        }
        [HttpPost]
        public async Task<JsonResult> TakeRateFeatureApplicabilityData(TakeRateParameters parameters)
        {
            Log.Debug(MethodBase.GetCurrentMethod().Name);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataPage;
            var model = await TakeRateViewModel.GetModel(DataContext, filter);

            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in model.Document.TakeRateData.RawData.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in model.Document.TakeRateData.RawData.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }

            Response.AddHeader("Content-Encoding", "gzip");
            Response.Filter = new GZipStream(Response.Filter,
                                 CompressionMode.Compress);

            return Json(new
            {
                FeatureApplicabilityData = rows,
                model.Document.Market
            });
        }

        [HttpPost]
        public async Task<ActionResult> ContextMenu(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.TakeRateDataItemDetails;
            var takeRateView = await TakeRateViewModel.GetModel(
                DataContext,
                filter);

            return PartialView("_ContextMenu", takeRateView);
        }

        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var takeRateView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), takeRateView);
        }

        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters,
                    Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action),
                parameters.GetActionSpecificParameters());
        }

        [HandleErrorWithJson]
        [HttpPost]
        public ActionResult SaveChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator
                .ValidateTakeRateParameters(DataContext, parameters,
                    TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            CheckModelAllowsEdit(parameters);

            var business = new TakeRateBusiness(DataContext, parameters);
            
            business.CalculateChanges();
            business.SaveChangeset();

            return Json(business.CurrentChangeSet);
        }
	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> GetLatestChangeset(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

	        var changeset = await DataContext.TakeRate.GetUnsavedChangesForUser(TakeRateFilter.FromTakeRateParameters(parameters));

	        return Json(changeset);
	    }

	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> RevertLatestChangeset(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

	        CheckModelAllowsEdit(parameters);

	        var changeset = await DataContext.TakeRate.RevertUnsavedChangesForUser(TakeRateFilter.FromTakeRateParameters(parameters));

	        return Json(changeset);
	    }

	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> ChangesetHistory(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Changeset;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

	        takeRateView.History = await DataContext.TakeRate.GetChangesetHistory(filter);

            return PartialView("_ChangesetHistory", takeRateView);
	    }
        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> ChangesetHistoryDetails(TakeRateParameters parameters)
        {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

            takeRateView.History = await DataContext.TakeRate.GetChangesetHistory(filter);
            takeRateView.HistoryDetails = await DataContext.TakeRate.GetChangesetHistoryDetails(filter);

            return PartialView("_ChangesetHistoryDetails", takeRateView);
        }

        public void Export(TakeRateParameters parameters)
        {
            var business = new TakeRateBusiness(DataContext, parameters);
            var exportData = business.ExportPricing();
            var fileName = string.Format("TakeRatePricingExport_{0:yyyyMMdd}_{1}_{2}.xlsx", 
                DateTime.Now,
                parameters.TakeRateId,
                parameters.MarketId);
            
            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment; filename=" + fileName);
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

            using (var stream = new MemoryStream())
            {
                exportData.SaveAs(stream);
                stream.WriteTo(Response.OutputStream);
                Response.Flush();
                Response.End();
            } 
        }
        public void ExportCpat(TakeRateParameters parameters)
        {
            var business = new TakeRateBusiness(DataContext, parameters);
            var exportData = business.ExportCpat();
            var fileName = string.Format("TakeRateCpatExport_{0:yyyyMMdd}_{1}.xlsx",
                DateTime.Now,
                parameters.TakeRateId);

            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment; filename=" + fileName);
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

            using (var stream = new MemoryStream())
            {
                exportData.SaveAs(stream);
                stream.WriteTo(Response.OutputStream);
                Response.Flush();
                Response.End();
            }
        }
        public void ExportChangeDetails(TakeRateParameters parameters)
        {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var business = new TakeRateBusiness(DataContext, parameters);
            var exportData = business.ExportChangeset();

            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment; filename=ChangeHistory.xlsx");
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

            using (var stream = new MemoryStream())
            {
                exportData.SaveAs(stream);
                stream.WriteTo(Response.OutputStream);
                Response.Flush();
                Response.End();
            }        
        }

	    [HandleErrorWithJson]
	    [HttpPost]
        [OutputCache(Duration = 10)]
	    public async Task<ActionResult> Filter(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Filter;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

	        return PartialView("_Filter", takeRateView);
	    }
	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> PersistChangeset(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters,
	            TakeRateParametersValidator.TakeRateIdentifierWithChangesetAndComment);

	        CheckModelAllowsEdit(parameters);

	        var persistedChangeset =
	            await DataContext.TakeRate.PersistChangeset(TakeRateFilter.FromTakeRateParameters(parameters));

	        return Json(persistedChangeset);
	    }
	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> PersistChangesetConfirm(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.TakeRateDataItemDetails;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

	        takeRateView.Changes = await DataContext.TakeRate.GetUnsavedChangesForUser(filter);

	        return PartialView("_PersistChangesetConfirm", takeRateView);
	    }
	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> Powertrain(TakeRateParameters parameters)
	    {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Powertrain;
            var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

            return PartialView("_Powertrain", takeRateView);
	    }

        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> UndoChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters,
                TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NO_EDITS);
            }
            var undoneChangeset =
                await DataContext.TakeRate.UndoChangeset(TakeRateFilter.FromTakeRateParameters(parameters));

            // TODO break this out into a separate call, as we want it to return as fast as possible
            //var rawData = await DataContext.TakeRate.GetRawData(filter);
            //var validationResults = Validator.Validate(rawData);
            //var savedValidationResults = await Validator.Persist(DataContext, filter, validationResults);

            return JsonGetSuccess(undoneChangeset);
        }

        [HandleErrorWithJson]
        [HttpPost]
        public async Task<ActionResult> UndoAllChangeset(TakeRateParameters parameters)
        {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            filter.Action = TakeRateDataItemAction.Changeset;
            var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
            if (!takeRateView.AllowEdit)
            {
                throw new InvalidOperationException(NO_EDITS);
            }
            var undoneChangeset = await DataContext.TakeRate.UndoAllChangeset(TakeRateFilter.FromTakeRateParameters(parameters));

            //// TODO break this out into a separate call, as we want it to return as fast as possible
            //var rawData = await DataContext.TakeRate.GetRawData(filter);
            //var validationResults = Validator.Validate(rawData);
            //var savedValidationResults = await Validator.Persist(DataContext, filter, validationResults);

            return JsonGetSuccess(undoneChangeset);
        }

	    [HandleErrorWithJson]
	    public async Task<ActionResult> AddNote(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.ModelPlusFeatureAndComment);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.AddNote;
	        var takeRateView = TakeRateViewModel.GetModel(DataContext, filter).Result;
	        if (!takeRateView.AllowEdit)
	        {
	            throw new InvalidOperationException(NO_EDITS);
	        }
	        var note = await DataContext.TakeRate.AddDataItemNote(TakeRateFilter.FromTakeRateParameters(parameters));

	        return Json(note, JsonRequestBehavior.AllowGet);
	    }

	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> GetValidation(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var validation = new FdpValidation();

	        if (parameters.MarketId.HasValue)
	        {
	            var business = new TakeRateBusiness(DataContext, parameters);
	            business.ValidateChangeset();

                validation = await DataContext.TakeRate.GetValidation(TakeRateFilter.FromTakeRateParameters(parameters));
	        }

	        return Json(validation);
	    }
	    public async Task<ActionResult> GetValidationSummary(TakeRateParameters parameters)
	    {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.ValidationSummary;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
            var validation = await DataContext.TakeRate.GetValidation(TakeRateFilter.FromTakeRateParameters(parameters));

	        takeRateView.Validation = validation;

            return PartialView("_ValidationSummary", takeRateView);
	    }
        //[HandleErrorWithJson]
        //[HttpPost]
        //public async Task<ActionResult> Validate(TakeRateParameters parameters)
        //{
        //    var validationResults = Enumerable.Empty<ValidationResult>();

        //    TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

        //    var filter = TakeRateFilter.FromTakeRateParameters(parameters);
        //    filter.Action = TakeRateDataItemAction.Validate;
        //    var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

        //    try
        //    {
        //        var interimResults = Validator.Validate(takeRateView.RawData);
        //        validationResults = await Validator.Persist(DataContext, filter, interimResults);
        //    }
        //    catch (ValidationException vex)
        //    {
        //        // Just in case someone has thrown an exception from the validation, which we don't actually want
        //        Log.Warning(vex);
        //    }
        //    catch (Exception ex)
        //    {
        //        Log.Error(ex);
        //    }

        //    return JsonGetSuccess(validationResults);
        //}

	    public ActionResult IgnoreValidationError(TakeRateParameters parameters)
	    {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);
	        DataContext.TakeRate.IgnoreValidationError(TakeRateFilter.FromTakeRateParameters(parameters));

	        return RedirectToRoute("TakeRateDataByMarket", new { takeRateId = parameters.TakeRateId, marketId = parameters.MarketId });
	    }

	    public ActionResult ValidationMessage(ValidationMessage message)
	    {
	        // Something is making a GET request to this page and I can't figure out what
	        return PartialView("_ValidationMessage", message);
	    }

        public async Task<JsonResult> Markets(TakeRateParameters parameters)
        {
            TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);
            var marketsGroups =
                await DataContext.TakeRate.ListAvailableMarketGroups(TakeRateFilter.FromTakeRateParameters(parameters));

            var markets = marketsGroups.SelectMany(mg => mg.Markets).Select(m => new
            {
                m.Name,
                m.GroupName,
                m.VariantCount,
                m.LastUpdated,
                m.UpdatedBy
            });

            return Json(markets, JsonRequestBehavior.AllowGet);
        }

	    #region "Private Methods"

	    private void CheckModelAllowsEdit(TakeRateParameters parameters)
	    {
	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Changeset;
	        var takeRateView = TakeRateViewModel.GetModel(DataContext, filter).Result;
	        if (!takeRateView.AllowEdit)
	        {
	            throw new InvalidOperationException(NO_EDITS);
	        }
	    }

	    private async Task<TakeRateViewModel> GetModelFromParameters(TakeRateParameters parameters)
	    {
	        return await TakeRateViewModel.GetModel(DataContext, TakeRateFilter.FromTakeRateParameters(parameters));
	    }

	    #endregion

	    #region "Private Constants"

	    private const string NO_EDITS = "Either you do not have permission, or the take rate file does not allow edits in the current state";

	    #endregion
    }
}