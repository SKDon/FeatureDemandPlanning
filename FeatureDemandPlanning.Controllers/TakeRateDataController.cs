using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using System.Linq;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using MvcSiteMapProvider.Web.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;

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
		[SiteMapTitle("DocumentName")]
		public async Task<ActionResult> TakeRateDataPage(TakeRateParameters parameters)
		{
			Log.Debug(MethodBase.GetCurrentMethod().Name);

			var filter = TakeRateFilter.FromTakeRateParameters(parameters);
			filter.Action = TakeRateDataItemAction.TakeRateDataPage;
			var model = await TakeRateViewModel.GetModel(DataContext, filter);

			ViewData["DocumentName"] = model.Document.UnderlyingOxoDocument.Name;
			ViewBag.Title = string.Format("{0} - {1} ({2}) - {3}", model.Document.Vehicle.Code,
				model.Document.Vehicle.ModelYear, model.Document.UnderlyingOxoDocument.Gateway, model.Document.TakeRateSummary.First().Version);

			return View("TakeRateDataPage", model);
		}
		[HttpPost]
		public async Task<ActionResult> TakeRateDataPartialPage(TakeRateParameters parameters)
		{
			Log.Debug(MethodBase.GetCurrentMethod().Name);

			var filter = TakeRateFilter.FromTakeRateParameters(parameters);
			filter.Action = TakeRateDataItemAction.TakeRateDataPage;
			var model = await TakeRateViewModel.GetModel(DataContext, filter);

			ViewData["DocumentName"] = model.Document.UnderlyingOxoDocument.Name;
			ViewBag.Title = string.Format("{0} - {1} ({2}) - {3}", model.Document.Vehicle.Code,
				model.Document.Vehicle.ModelYear, model.Document.UnderlyingOxoDocument.Gateway, model.Document.TakeRateSummary.First().Version);

			return PartialView("_TakeRateData", model);       
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
				.ValidateTakeRateParameters(DataContext, parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

			return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
		}
		[HandleErrorWithJson]
		[HttpPost]
		public async Task<ActionResult> SaveChangeset(TakeRateParameters parameters)
		{
			TakeRateParametersValidator
				.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

			await CheckModelAllowsEdit(parameters);

		    var changeset = parameters.Changeset;
            var dataChange = changeset.Changes.First();

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);

            if (dataChange.IsFeatureChange)
		    {
		        CalculateFeatureChange(parameters);
		    }
            else if (dataChange.IsModelSummary)
            {
                CalculateModelChange(parameters);
            }
            else if (dataChange.IsWholeMarketChange)
            {
                CalculateMarketChange(parameters);
            }
            else if (dataChange.IsPowertrainChange)
            {
                CalculatePowertrainChange(parameters);
            }

		    var savedChangeset = await DataContext.TakeRate.SaveChangeset(filter, changeset);

            // TODO break this out into a separate call, as we want it to return as fast as possible
            var rawData = await DataContext.TakeRate.GetRawData(filter);
		    var validationResults = Validator.Validate(rawData);
		    var savedValidationResults = await Validator.Persist(DataContext, filter, validationResults);

			return Json(savedChangeset);
		}
        // For a feature change, we simply re-compute the % take if the volume has been altered and vice versa
        // The feature mix will then need to be recalculated
	    private async void CalculateFeatureChange(TakeRateParameters parameters)
	    {
            var changeset = parameters.Changeset;
            var dataChange = parameters.Changeset.Changes.First();
            
            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            var rawData = await DataContext.TakeRate.GetRawData(filter);
           
            var modelId = dataChange.GetModelId();
            var modelVolumes = rawData.SummaryItems.Where(s => s.ModelId.HasValue || s.FdpModelId.HasValue).Sum(s => s.Volume);

            // Get the original values from raw data

            var modelVolume = dataChange.IsFdpModel ? rawData.GetFdpModelVolume(modelId) : rawData.GetModelVolume(modelId);
            var existingFeature = rawData.DataItems.FirstOrDefault(d => IsMatchingModel(dataChange, d) && IsMatchingFeature(dataChange, d));
            var existingFeatureVolumes = rawData.DataItems.Where(d => !IsMatchingModel(dataChange, d) && IsMatchingFeature(dataChange, d)).Sum(d => d.Volume);
            var existingFeatureMix = rawData.FeatureMixItems.FirstOrDefault(f => IsMatchingFeatureMix(dataChange, f));

            switch (dataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    dataChange.Volume = (int)(modelVolume * decimal.Divide(dataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    break;
                case TakeRateResultMode.Raw:
                    dataChange.PercentageTakeRate = (dataChange.Volume / (decimal)modelVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

	        // Get the original values

	        if (existingFeature != null)
	        {
	            dataChange.OriginalPercentageTakeRate = existingFeature.PercentageTakeRate;
	            dataChange.OriginalVolume = existingFeature.Volume;
	            dataChange.FdpVolumeDataItemId = existingFeature.FdpVolumeDataItemId;
	        }

	        // Update the feature mix for the feature in question

	        var featureMixDataChange = new DataChange(dataChange)
	        {
	            PercentageTakeRate = ((existingFeatureVolumes + dataChange.Volume)/(decimal) modelVolumes)*100, Volume = existingFeatureVolumes + dataChange.Volume, ModelIdentifier = string.Empty
	        };
	        if (existingFeatureMix != null)
	        {
	            featureMixDataChange.OriginalPercentageTakeRate = existingFeatureMix.PercentageTakeRate;
	            featureMixDataChange.OriginalVolume = existingFeatureMix.Volume;
	            featureMixDataChange.FdpTakeRateFeatureMixId = existingFeatureMix.FdpTakeRateFeatureMixId;
	        }
	        changeset.Changes.Add(featureMixDataChange);
	    }

        // For a feature change, we simply re-compute the % take if the volume has been altered and vice versa
        // The feature mix will then need to be recalculated
        private async void CalculatePowertrainChange(TakeRateParameters parameters)
        {
            var changeset = parameters.Changeset;
            var dataChange = parameters.Changeset.Changes.First();

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            var rawData = await DataContext.TakeRate.GetRawData(filter);

            var marketVolume = rawData.SummaryItems.Where(s => !string.IsNullOrEmpty(s.ModelIdentifier)).Sum(s => s.Volume);

            // Get the original values from raw data
            var existingDerivative = rawData.PowertrainDataItems.FirstOrDefault(p => p.DerivativeCode == dataChange.DerivativeCode);
            var affectedModels = rawData.SummaryItems.Where(s => s.DerivativeCode == dataChange.DerivativeCode).ToList();

            switch (dataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    dataChange.Volume = (int)(marketVolume * decimal.Divide(dataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    break;
                case TakeRateResultMode.Raw:
                    dataChange.PercentageTakeRate = (dataChange.Volume / (decimal)marketVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // Get the original values

            if (existingDerivative != null)
            {
                dataChange.OriginalPercentageTakeRate = existingDerivative.PercentageTakeRate;
                dataChange.OriginalVolume = existingDerivative.Volume;
                dataChange.FdpPowertrainDataItemId = existingDerivative.FdpPowertrainDataItemId;
            }

            // Update the mix for each of the models under the derivative in question
            // Split the volume and percentage take rate equally amongst all models

            var rawTakeRateSummaryItems = affectedModels as IList<RawTakeRateSummaryItem> ?? affectedModels.ToList();
            var numberOfAffectedModels = rawTakeRateSummaryItems.Count();
            var volumePerModel = dataChange.Volume / numberOfAffectedModels;
            var remainder = dataChange.Volume % numberOfAffectedModels;

            var counter = 0;
            foreach (var modelDataChange in rawTakeRateSummaryItems.Select(affectedModel => new DataChange(dataChange)
            {
                Volume = volumePerModel,
                PercentageTakeRate = decimal.Divide(volumePerModel.Value, dataChange.Volume.Value) * 100,
                FdpTakeRateSummaryId = affectedModel.FdpTakeRateSummaryId,
                OriginalVolume = affectedModel.Volume,
                OriginalPercentageTakeRate = affectedModel.PercentageTakeRate,
                ModelIdentifier = affectedModel.ModelIdentifier
            }))
            {
                if (++counter == numberOfAffectedModels)
                {
                    modelDataChange.Volume += remainder;
                }
                changeset.Changes.Add(modelDataChange);

                var affectedFeatures = rawData.DataItems.Where(f => IsMatchingModel(modelDataChange, f)).ToList();
                var change = modelDataChange;
                foreach (var featureDataChange in affectedFeatures.Select(affectedFeature => new DataChange(dataChange)
                {
                    Volume = (int)(change.Volume * affectedFeature.PercentageTakeRate),
                    PercentageTakeRate = affectedFeature.PercentageTakeRate * 100,
                    FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
                    OriginalVolume = affectedFeature.Volume,
                    OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
                    FeatureIdentifier = affectedFeature.FeatureIdentifier,
                    ModelIdentifier = change.ModelIdentifier
                }))
                {
                    changeset.Changes.Add(featureDataChange);
                }
            }
        }

	    private async void CalculateModelChange(TakeRateParameters parameters)
	    {
	        var changeset = parameters.Changeset;
	        var dataChange = parameters.Changeset.Changes.First();

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        var rawData = await DataContext.TakeRate.GetRawData(filter);

	        var marketVolume = rawData.GetMarketVolume();
	        var existingModelVolumes = rawData.SummaryItems.Where(s => (s.ModelId.HasValue || s.FdpModelId.HasValue) && IsMatchingModel(dataChange, s)).Sum(s => s.Volume);
	        var existingModel = rawData.SummaryItems.FirstOrDefault(s => IsMatchingModel(dataChange, s));
	        var affectedFeatures = rawData.DataItems.Where(f => IsMatchingModel(dataChange, f));

	        switch (dataChange.Mode)
	        {
	            case TakeRateResultMode.PercentageTakeRate:
	                dataChange.Volume = (int) (marketVolume*decimal.Divide(dataChange.PercentageTakeRate.GetValueOrDefault(), 100));
	                break;
	            case TakeRateResultMode.Raw:
	                dataChange.PercentageTakeRate = (dataChange.Volume/(decimal) marketVolume)*100;
	                break;
	            case TakeRateResultMode.NotSet:
	                break;
	            default:
	                throw new ArgumentOutOfRangeException();
	        }

	        if (existingModel != null)
	        {
	            dataChange.OriginalPercentageTakeRate = existingModel.PercentageTakeRate;
	            dataChange.OriginalVolume = existingModel.Volume;
	            dataChange.FdpTakeRateSummaryId = existingModel.FdpTakeRateSummaryId;
	        }

	        // Re-compute all affected features

	        foreach (var featureDataChange in affectedFeatures.Select(affectedFeature => new DataChange(dataChange)
	        {
	            Volume = (int) (dataChange.Volume*affectedFeature.PercentageTakeRate), PercentageTakeRate = affectedFeature.PercentageTakeRate*100, FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId, OriginalVolume = affectedFeature.Volume, OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate, FeatureIdentifier = affectedFeature.FeatureIdentifier
	        }))
	        {
	            changeset.Changes.Add(featureDataChange);
	        }

	        // Re-compute the feature mix across the board

	        foreach (var featureMixDataChange in rawData.FeatureMixItems.Select(featureMixItem => new DataChange(dataChange)
	        {
	            PercentageTakeRate = featureMixItem.PercentageTakeRate*100, Volume = (int) ((existingModelVolumes + dataChange.Volume)*featureMixItem.PercentageTakeRate), ModelIdentifier = string.Empty, OriginalPercentageTakeRate = featureMixItem.PercentageTakeRate, OriginalVolume = featureMixItem.Volume, FdpTakeRateFeatureMixId = featureMixItem.FdpTakeRateFeatureMixId, FeatureIdentifier = featureMixItem.FeatureIdentifier
	        }))
	        {
	            changeset.Changes.Add(featureMixDataChange);
	        }
	    }

	    private async void CalculateMarketChange(TakeRateParameters parameters)
	    {
	        var changeset = parameters.Changeset;
	        var dataChange = parameters.Changeset.Changes.First();

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        var rawData = await DataContext.TakeRate.GetRawData(filter);

            var marketVolume = rawData.GetAllMarketVolume();
            
            switch (dataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    dataChange.Volume = (int)(marketVolume * decimal.Divide(dataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    break;
                case TakeRateResultMode.Raw:
                    dataChange.PercentageTakeRate = (dataChange.Volume / (decimal)marketVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
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

	        await CheckModelAllowsEdit(parameters);

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

	        await CheckModelAllowsEdit(parameters);

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
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifierWithChangeset);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Changeset;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
	        if (!takeRateView.AllowEdit)
	        {
	            throw new InvalidOperationException(NO_EDITS);
	        }
	        var undoneChangeset = await DataContext.TakeRate.UndoChangeset(TakeRateFilter.FromTakeRateParameters(parameters));

	        return JsonGetSuccess(undoneChangeset);
	    }

	    [HandleErrorWithJson]
	    public async Task<ActionResult> AddNote(TakeRateParameters parameters)
	    {
	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.ModelPlusFeatureAndComment);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.AddNote;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
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

	        var validation = await DataContext.TakeRate.GetValidation(TakeRateFilter.FromTakeRateParameters(parameters));

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
	    [HandleErrorWithJson]
	    [HttpPost]
	    public async Task<ActionResult> Validate(TakeRateParameters parameters)
	    {
	        var validationResults = Enumerable.Empty<ValidationResult>();

	        TakeRateParametersValidator.ValidateTakeRateParameters(DataContext, parameters, TakeRateParametersValidator.TakeRateIdentifier);

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Validate;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);

	        try
	        {
	            var interimResults = Validator.Validate(takeRateView.RawData);
	            validationResults = await Validator.Persist(DataContext, filter, interimResults);
	        }
	        catch (ValidationException vex)
	        {
	            // Just in case someone has thrown an exception from the validation, which we don't actually want
	            Log.Warning(vex);
	        }
	        catch (Exception ex)
	        {
	            Log.Error(ex);
	        }

	        return JsonGetSuccess(validationResults);
	    }

	    public ActionResult ValidationMessage(ValidationMessage message)
	    {
	        // Something is making a GET request to this page and I can't figure out what
	        return PartialView("_ValidationMessage", message);
	    }

	    #region "Private Methods"

	    private async Task CheckModelAllowsEdit(TakeRateParameters parameters)
	    {
	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        filter.Action = TakeRateDataItemAction.Changeset;
	        var takeRateView = await TakeRateViewModel.GetModel(DataContext, filter);
	        if (!takeRateView.AllowEdit)
	        {
	            throw new InvalidOperationException(NO_EDITS);
	        }
	    }

	    private async Task<TakeRateViewModel> GetModelFromParameters(TakeRateParameters parameters)
	    {
	        return await TakeRateViewModel.GetModel(DataContext, TakeRateFilter.FromTakeRateParameters(parameters));
	    }

	    private static bool IsMatchingModel(DataChange dataChange, RawTakeRateDataItem dataItem)
	    {
	        return (dataChange.IsFdpModel && dataItem.FdpModelId == dataChange.GetModelId()) || (!dataChange.IsFdpModel && dataItem.ModelId == dataChange.GetModelId());
	    }

	    private static bool IsMatchingModel(DataChange dataChange, RawTakeRateSummaryItem summaryItem)
	    {
	        return (dataChange.IsFdpModel && summaryItem.FdpModelId == dataChange.GetModelId()) || (!dataChange.IsFdpModel && summaryItem.ModelId == dataChange.GetModelId());
	    }

	    private static bool IsMatchingFeature(DataChange dataChange, RawTakeRateDataItem dataItem)
	    {
	        return (dataChange.IsFdpFeature && dataItem.FdpFeatureId == dataChange.GetFeatureId()) || (dataChange.IsFeature && dataItem.FeatureId == dataChange.GetFeatureId()) || (dataChange.IsFeaturePack && !dataItem.FeatureId.HasValue && dataItem.FeaturePackId == dataChange.GetFeatureId());
	    }

	    private static bool IsMatchingFeatureMix(DataChange dataChange, RawTakeRateFeatureMixItem mixItem)
	    {
	        return (dataChange.IsFdpFeature && mixItem.FdpFeatureId == dataChange.GetFeatureId()) || (dataChange.IsFeature && mixItem.FeatureId == dataChange.GetFeatureId()) || (dataChange.IsFeaturePack && !mixItem.FeatureId.HasValue && mixItem.FeaturePackId == dataChange.GetFeatureId());
	    }

	    #endregion

	    #region "Private Constants"

	    private const string NO_EDITS = "Either you do not have permission, or the take rate file does not allow edits in the current state";

	    #endregion
	}
}