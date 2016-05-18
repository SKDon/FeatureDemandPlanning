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
using System.Globalization;
using System.Reflection;
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

        #region "Properties"

	    public FdpChangeset CurrentChangeSet { get; set; }
        public RawTakeRateData CurrentData { get; set; }
        public int CurrentModelId { get; set; }
        public DataChange CurrentDataChange { get; set; }
        public int CurrentModelVolume { get; set; }
        public int CurrentModelVolumes { get; set; }

        public RawTakeRateDataItem ExistingFeature { get; set; }
        public int ExistingFeatureVolumes { get; set; }
        public RawTakeRateFeatureMixItem ExistingFeatureMix { get; set; }

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

            CurrentData = await DataContext.TakeRate.GetRawData(TakeRateFilter.FromTakeRateParameters(parameters));
            CurrentChangeSet = parameters.Changeset;
            CurrentDataChange = CurrentChangeSet.Changes.First();

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);

            if (CurrentDataChange.IsFeatureChange)
		    {
		        InitialiseDataForChange();
                CalculateFeatureChange();
                CalculateStandardFeatureChange();
                CalculatePackFeatureChange();
		    }
            else if (CurrentDataChange.IsModelSummary)
            {
                CalculateModelChange(parameters);
            }
            else if (CurrentDataChange.IsWholeMarketChange)
            {
                InitialiseDataForChange();
                CalculateMarketChange();
                CalculateModelsForMarket();
            }
            else if (CurrentDataChange.IsPowertrainChange)
            {
                CalculatePowertrainChange(parameters);
            }

		    var savedChangeset = await DataContext.TakeRate.SaveChangeset(filter, CurrentChangeSet);

            // TODO break this out into a separate call, as we want it to return as fast as possible
            var rawData = await DataContext.TakeRate.GetRawData(filter);
		    var validationResults = Validator.Validate(rawData);
		    var savedValidationResults = await Validator.Persist(DataContext, filter, validationResults);

			return Json(savedChangeset);
		}

        private void InitialiseDataForChange()
        {
            CurrentDataChange = CurrentChangeSet.Changes.First();
            CurrentModelId = CurrentDataChange.GetModelId().GetValueOrDefault();
            CurrentModelVolumes = CurrentData.SummaryItems.Where(s => s.ModelId.HasValue).Sum(s => s.Volume);
            CurrentModelVolume = GetModelVolume(CurrentModelId);

            ExistingFeature =
                CurrentData.DataItems.FirstOrDefault(d => IsMatchingModel(CurrentDataChange, d) && IsMatchingFeature(CurrentDataChange, d));
            ExistingFeatureVolumes =
                CurrentData.DataItems.Where(d => !IsMatchingModel(CurrentDataChange, d) && IsMatchingFeature(CurrentDataChange, d))
                    .Sum(d => d.Volume);
            ExistingFeatureMix = CurrentData.FeatureMixItems.FirstOrDefault(f => IsMatchingFeatureMix(CurrentDataChange, f));
        }

	    private void CalculateStandardFeatureChange()
	    {
            // If this is a feature within an exclusive feature group and not the standard feature, recalculate the percentage take and volume
            // standard feature as the model volume less the volume of any options in the group

            if (ExistingFeature == null) return;

            var efgItems = CurrentData.DataItems.Where(g => IsMatchingModel(CurrentDataChange, g) && g.ExclusiveFeatureGroup == ExistingFeature.ExclusiveFeatureGroup).ToList();
            var optionalFeatures = efgItems.Where(g => !g.IsStandardFeatureInGroup).ToList();
            var standardFeature = efgItems.FirstOrDefault(g => g.IsStandardFeatureInGroup);

	        if (standardFeature == null || !optionalFeatures.Any() || standardFeature.FeatureId == ExistingFeature.FeatureId) return;

	        var optionalFeaturePercentageTakeRate =
                optionalFeatures.Where(o => o.FeatureIdentifier != CurrentDataChange.FeatureIdentifier).Sum(o => o.PercentageTakeRate) + CurrentDataChange.PercentageTakeRateAsFraction.GetValueOrDefault();

	        var standardFeaturePercentageTakeRate = (1 - optionalFeaturePercentageTakeRate);
	        var standardFeatureVolume = 0;

	        // We cannot allow a standard feature take rate of greater than 100%
	        if (standardFeaturePercentageTakeRate > 1)
	        {
	            standardFeaturePercentageTakeRate = 1;
	        }
	        // We cannot allow a standard feature take rate of less than 0%
	        if (standardFeaturePercentageTakeRate < 0)
	        {
	            standardFeaturePercentageTakeRate = 0;
	        }

	        if (standardFeaturePercentageTakeRate >= 1)
	        {
	            // If 100% take, simply use the model volume, instead of trying to calculate as a combination of optional feature volumes
	            // This to do do with the fact we round fractional vehicle volumes down
	            standardFeatureVolume = CurrentModelVolume;
	        }
	        else if (standardFeaturePercentageTakeRate > 0)
	        {
	            standardFeatureVolume = (int)(CurrentModelVolume * standardFeaturePercentageTakeRate);
	        }
	        var standardFeatureDataChange = new DataChange(CurrentDataChange)
	        {
	            FeatureIdentifier = "O" + standardFeature.FeatureId,
	            Volume = standardFeatureVolume,
	            PercentageTakeRate = standardFeaturePercentageTakeRate * 100,
	            // Make sure we use the id of the standard feature item, not the original data change item
	            FdpVolumeDataItemId = standardFeature.FdpVolumeDataItemId == 0 ? (int?)null : standardFeature.FdpVolumeDataItemId,
                Mode = CurrentDataChange.Mode,
                OriginalPercentageTakeRate = standardFeature.PercentageTakeRate,
                OriginalVolume = standardFeature.Volume
	        };
	        CurrentChangeSet.Changes.Add(standardFeatureDataChange);

	        var existingStandardFeatureVolumes =
	            CurrentData.DataItems.Where(d => !IsMatchingModel(standardFeatureDataChange, d) && IsMatchingFeature(standardFeatureDataChange, d))
	                .Sum(d => d.Volume);

	        var standardFeatureMixPercentageTakeRate = (existingStandardFeatureVolumes + standardFeatureDataChange.Volume.GetValueOrDefault()) /
	                                                   (decimal)CurrentModelVolumes;
	        var standardFeatureMixVolume = 0;
	        var existingStandardFeatureMix = CurrentData.FeatureMixItems.First(f => IsMatchingFeatureMix(standardFeatureDataChange, f));

	        if (standardFeatureMixPercentageTakeRate > 1)
	        {
	            standardFeatureMixPercentageTakeRate = 1;
	        }
	        if (standardFeatureMixPercentageTakeRate < 0)
	        {
	            standardFeatureMixPercentageTakeRate = 0;
	        }

	        if (standardFeaturePercentageTakeRate >= 1)
	        {
	            standardFeatureMixVolume = CurrentModelVolumes;
	        }
	        else if (standardFeatureMixPercentageTakeRate > 0)
	        {
	            standardFeatureMixVolume = (int)(CurrentModelVolumes * standardFeatureMixPercentageTakeRate);
	        }
	        var standardFeatureMixDataChange = new DataChange(standardFeatureDataChange)
	        {
	            PercentageTakeRate = standardFeatureMixPercentageTakeRate * 100,
	            Volume = standardFeatureMixVolume,
	            ModelIdentifier = string.Empty,
	            FdpVolumeDataItemId = null,
	            FdpTakeRateFeatureMixId = existingStandardFeatureMix == null ? (int?)null : existingStandardFeatureMix.FdpTakeRateFeatureMixId,
                Mode = CurrentDataChange.Mode,
                OriginalPercentageTakeRate = existingStandardFeatureMix.PercentageTakeRate,
                OriginalVolume = existingStandardFeatureMix.Volume
	        };
	        CurrentChangeSet.Changes.Add(standardFeatureMixDataChange);
	    }
	    private void CalculatePackFeatureChange()
	    {
	        // If the feature is part of a pack (and only a pack i.e. cannot be chosen stand-alone), then all pack feature take rates must be
            // equivalent

            // If the feature is part of multiple packs, then the take rate for the feature will be the sum of the take rates from all packs

            if (ExistingFeature == null) return;
            
            if (string.IsNullOrEmpty(ExistingFeature.OxoCode) || string.IsNullOrEmpty(ExistingFeature.PackName)) return;

            // 1. Feature must be in the same pack as the feature / pack being edited
            // 2. Feature cannot be standard for the model (as will have 100% take)
            // 3. Feature is ignored if not available for the model (as will have 0% take)
            // 4. Cannot be the same feature being edited (else we will end up with cyclic dependencies)
            var packItems = CurrentData.DataItems.Where(f => IsMatchingModel(CurrentDataChange, f) &&
                !string.IsNullOrEmpty(f.PackName) &&
                f.PackName.Equals(ExistingFeature.PackName, StringComparison.OrdinalIgnoreCase) &&
                !f.OxoCode.Contains("S") &&
                !f.OxoCode.Contains("NA")).ToList();

	        if (!packItems.Any())
	        {
	            return;
	        }

            // Exclude the item being edited from the list

	        packItems =
	            packItems.Where(p => ExistingFeature.FeatureId.GetValueOrDefault() != p.FeatureId.GetValueOrDefault()).ToList();

            // If the feature is optional and not the pack itself, we only update the rest of the pack if the percentage take rate is now less than
            // the take rate for the pack
            // Optional features that can be chosen outside of a pack can have a higher take rate than the pack itself due to the fact they may be
            // chosen individually

	        var parentPackItem = packItems.FirstOrDefault(p => !p.FeatureId.HasValue && p.FeaturePackId.HasValue);
            if (ExistingFeature.IsOptionalFeatureInGroup && ExistingFeature.FeatureId.HasValue && parentPackItem != null && CurrentDataChange.PercentageTakeRate > parentPackItem.PercentageTakeRate) return;

	        var packDataChanges = new List<DataChange>();
            foreach (var packItem in packItems)
	        {
	            var packDataChange = new DataChange(CurrentDataChange)
	            {
	                FdpVolumeDataItemId = packItem.FdpVolumeDataItemId,
	                Volume = CurrentDataChange.Volume,
	                PercentageTakeRate = CurrentDataChange.PercentageTakeRate,
                    Mode = CurrentDataChange.Mode,
                    OriginalPercentageTakeRate = packItem.PercentageTakeRate,
                    OriginalVolume = packItem.Volume,
                    FeatureIdentifier = packItem.FeatureIdentifier
	            };
	            CurrentChangeSet.Changes.Add(packDataChange);

                // Compute the feature mix for the pack item

                var existingPackFeatureVolumes =
	            CurrentData.DataItems.Where(d => !IsMatchingModel(packDataChange, d) && IsMatchingFeature(packDataChange, d))
	                .Sum(d => d.Volume);

	            var packItemFeatureMixPercentageTakeRate = (existingPackFeatureVolumes + packDataChange.Volume.GetValueOrDefault()) /
	                                                       (decimal)CurrentModelVolumes;
	            var packItemFeatureMixVolume = 0;
	            var existingPackItemFeatureMix = CurrentData.FeatureMixItems.FirstOrDefault(f => IsMatchingFeatureMix(packDataChange, f));

	            if (packItemFeatureMixPercentageTakeRate > 1)
	            {
	                packItemFeatureMixPercentageTakeRate = 1;
	            }
	            if (packItemFeatureMixPercentageTakeRate < 0)
	            {
	                packItemFeatureMixPercentageTakeRate = 0;
	            }

	            if (packItemFeatureMixPercentageTakeRate >= 1)
	            {
	                packItemFeatureMixVolume = CurrentModelVolumes;
	            }
	            else if (packItemFeatureMixPercentageTakeRate > 0)
	            {
	                packItemFeatureMixVolume = (int)(CurrentModelVolumes * packItemFeatureMixPercentageTakeRate);
	            }

	            var packFeatureMixDataChange = new DataChange(packDataChange)
	            {
	                PercentageTakeRate = packItemFeatureMixPercentageTakeRate*100,
	                Volume = packItemFeatureMixVolume,
	                ModelIdentifier = string.Empty,
	                FdpVolumeDataItemId = null,
	                FdpTakeRateFeatureMixId =
	                    existingPackItemFeatureMix == null
	                        ? (int?) null
	                        : existingPackItemFeatureMix.FdpTakeRateFeatureMixId,
                    OriginalVolume = existingPackItemFeatureMix == null ? 0 : existingPackItemFeatureMix.Volume,
                    OriginalPercentageTakeRate = existingPackItemFeatureMix == null ? 0 : existingPackItemFeatureMix.PercentageTakeRate
	            };

                CurrentChangeSet.Changes.Add(packFeatureMixDataChange);
                packDataChanges.Add(packDataChange);
	        }

            // The final thing we need to do is for any pack items that have been adjusted, check if they also belong to an exclusive feature group
            // The exclusive feature group will need to be changed accordingly, including potentially reducing the rate of any standard feature

	        foreach (var packDataChange in packDataChanges)
	        {
	            CurrentDataChange = packDataChange;
                ExistingFeature = CurrentData.DataItems.FirstOrDefault(d => IsMatchingModel(CurrentDataChange, d) && IsMatchingFeature(CurrentDataChange, d));
                
                CalculateStandardFeatureChange();
	        }
	    }
        // For a feature change, we simply re-compute the % take if the volume has been altered and vice versa
        // The feature mix will then need to be recalculated
	    private void CalculateFeatureChange()
	    {
	        switch (CurrentDataChange.Mode)
	        {
	            case TakeRateResultMode.PercentageTakeRate:
	                CurrentDataChange.Volume =
	                    (int) (CurrentModelVolume*decimal.Divide(CurrentDataChange.PercentageTakeRate.GetValueOrDefault(), 100));
	                break;
	            case TakeRateResultMode.Raw:
                    CurrentDataChange.PercentageTakeRate = (CurrentDataChange.Volume / (decimal)CurrentModelVolume) * 100;
	                break;
	            case TakeRateResultMode.NotSet:
	                break;
	            default:
	                throw new ArgumentOutOfRangeException();
	        }

	        // Get the original values

	        if (ExistingFeature != null)
	        {
                CurrentDataChange.OriginalPercentageTakeRate = ExistingFeature.PercentageTakeRate;
                CurrentDataChange.OriginalVolume = ExistingFeature.Volume;
                CurrentDataChange.FdpVolumeDataItemId = ExistingFeature.FdpVolumeDataItemId == 0 ? (int?)null : ExistingFeature.FdpVolumeDataItemId;
	        }

	        // Update the feature mix for the feature in question

            var featureMixDataChange = new DataChange(CurrentDataChange)
	        {
                PercentageTakeRate = ((ExistingFeatureVolumes + CurrentDataChange.Volume) / (decimal)CurrentModelVolumes) * 100,
                Volume = ExistingFeatureVolumes + CurrentDataChange.Volume,
	            ModelIdentifier = string.Empty,
                Mode = CurrentDataChange.Mode
	        };
	        if (ExistingFeatureMix != null)
	        {
	            featureMixDataChange.OriginalPercentageTakeRate = ExistingFeatureMix.PercentageTakeRate;
	            featureMixDataChange.OriginalVolume = ExistingFeatureMix.Volume;
	            featureMixDataChange.FdpVolumeDataItemId = null;
	            featureMixDataChange.FdpTakeRateFeatureMixId = ExistingFeatureMix.FdpTakeRateFeatureMixId == 0 ? (int?)null : ExistingFeatureMix.FdpTakeRateFeatureMixId;
	        }
	        CurrentChangeSet.Changes.Add(featureMixDataChange); 
	    }
	    private int GetModelVolume(int modelId)
	    {
            return CurrentData.GetModelVolume(modelId);
	    }
        private async void CalculatePowertrainChange(TakeRateParameters parameters)
        {
            var changeset = parameters.Changeset;
            var dataChange = parameters.Changeset.Changes.First();

            var filter = TakeRateFilter.FromTakeRateParameters(parameters);
            var rawData = await DataContext.TakeRate.GetRawData(filter);

            var marketVolume = rawData.SummaryItems.Where(s => string.IsNullOrEmpty(s.ModelIdentifier)).Select(s => s.Volume).FirstOrDefault();

            // Get the original values from raw data
            var existingDerivative = rawData.PowertrainDataItems.FirstOrDefault(p => p.DerivativeCode == dataChange.DerivativeCode);
            var affectedModels = rawData.SummaryItems.Where(s => s.DerivativeCode == dataChange.DerivativeCode).ToList();
            var unaffectedModels = rawData.SummaryItems.Where(s => !string.IsNullOrEmpty(s.ModelIdentifier) && s.DerivativeCode != dataChange.DerivativeCode && !string.IsNullOrEmpty(s.DerivativeCode)).ToList();
            
            dataChange.Volume = (int)(marketVolume * decimal.Divide(dataChange.PercentageTakeRate.GetValueOrDefault(), 100));

            var modelVolume = unaffectedModels.Select(m => m.Volume).Sum() + dataChange.Volume.GetValueOrDefault();

            var numberOfAffectedModels = affectedModels.Count();
            var volumePerModel = dataChange.Volume / numberOfAffectedModels;
            var remainder = dataChange.Volume % numberOfAffectedModels;
            
            // Get the original values

            if (existingDerivative != null)
            {
                dataChange.OriginalPercentageTakeRate = existingDerivative.PercentageTakeRate;
                dataChange.OriginalVolume = existingDerivative.Volume;
                dataChange.FdpPowertrainDataItemId = existingDerivative.FdpPowertrainDataItemId;
            }

            // Update the mix for each of the models under the derivative in question
            // Split the volume and percentage take rate equally amongst all models

            var counter = 0;
            foreach (var modelDataChange in affectedModels.Select(affectedModel => new DataChange(dataChange)
            {
                Volume = volumePerModel,
                PercentageTakeRate = decimal.Divide(volumePerModel.Value, marketVolume) * 100,
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

            // Calculate the feature mix changes now that the volumes for the models have changed
            foreach (var featureMixDataChange in rawData.FeatureMixItems.Select(featureMixItem => new DataChange(dataChange)
            {
                ModelIdentifier = string.Empty,
                OriginalPercentageTakeRate = featureMixItem.PercentageTakeRate,
                OriginalVolume = featureMixItem.Volume,
                FdpTakeRateFeatureMixId = featureMixItem.FdpTakeRateFeatureMixId,
                FeatureIdentifier = featureMixItem.FeatureIdentifier
            }))
            {
                // Get the total volume of the feature for unaffected models

                var featureVolume = 0;
                var changedFeatureVolume = 0;

                featureVolume += rawData.DataItems
                    .Where(f => f.FeatureIdentifier == featureMixDataChange.FeatureIdentifier &&
                                unaffectedModels.Select(m => m.ModelId.GetValueOrDefault()).Contains(f.ModelId.GetValueOrDefault()))
                    .Select(f => f.Volume)
                    .Sum();

                // Get the total volume for affected features

                changedFeatureVolume +=
                    changeset.Changes.Where(c => c.FeatureIdentifier == featureMixDataChange.FeatureIdentifier && c.IsFeatureChange)
                        .Select(f => f.Volume.GetValueOrDefault())
                        .Sum();

                featureMixDataChange.Volume = featureVolume + changedFeatureVolume;
                featureMixDataChange.PercentageTakeRate = decimal.Divide(featureVolume + changedFeatureVolume, modelVolume) * 100;

                if (featureMixDataChange.Volume != featureMixDataChange.OriginalVolume.GetValueOrDefault() ||
                    featureMixDataChange.PercentageTakeRate != featureMixDataChange.OriginalPercentageTakeRate)
                {
                    changeset.Changes.Add(featureMixDataChange);
                }
            }
        }

	    private async void CalculateModelChange(TakeRateParameters parameters)
	    {
	        var changeset = parameters.Changeset;
	        var dataChange = parameters.Changeset.Changes.First();

	        var filter = TakeRateFilter.FromTakeRateParameters(parameters);
	        var rawData = await DataContext.TakeRate.GetRawData(filter);

            var marketVolume = CurrentData.SummaryItems.First(s => !s.ModelId.HasValue).Volume;
	        var existingModel = rawData.SummaryItems.FirstOrDefault(s => IsMatchingModel(dataChange, s));
	        var affectedFeatures =
	            rawData.DataItems.Where(f => IsMatchingModel(dataChange, f) && !f.IsNonApplicableFeatureInGroup);
            var existingModelVolumes = rawData.SummaryItems.Where(m => m.ModelId != dataChange.GetModelId() && m.ModelId.HasValue).Sum(m => m.Volume);

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

	        // Re-compute all affected features and feature mix

	        foreach (var affectedFeature in affectedFeatures)
	        {
	            var volume = (int) (dataChange.Volume*affectedFeature.PercentageTakeRate);
                if (volume == affectedFeature.Volume) continue;

	            var featureDataChange = new DataChange(dataChange)
	            {
	                Volume = (int) (dataChange.Volume*affectedFeature.PercentageTakeRate),
	                PercentageTakeRate = affectedFeature.PercentageTakeRate*100,
	                FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
	                OriginalVolume = affectedFeature.Volume,
	                OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
	                FeatureIdentifier = affectedFeature.FeatureIdentifier,
	                FdpTakeRateSummaryId = null,
                    Mode = dataChange.Mode
	            };

                changeset.Changes.Add(featureDataChange);

	            var existingFeatureMix =
	                rawData.FeatureMixItems.First(f => f.FeatureIdentifier == affectedFeature.FeatureIdentifier);
	            var featureMixVolume =
	                rawData.DataItems.Where(d => d.FeatureId == dataChange.GetFeatureId() && 
                        d.ModelId != dataChange.GetModelId()).Sum(d => d.Volume) + featureDataChange.Volume;
                var updatedMarketVolume = existingModelVolumes + dataChange.Volume;
	            var featureMixPercentageTakeRate = featureMixVolume/(decimal) updatedMarketVolume;

	            if (existingFeatureMix.Volume == featureMixVolume &&
	                existingFeatureMix.PercentageTakeRate == featureMixPercentageTakeRate) continue;

	            var featureMixDataChange = new DataChange(dataChange)
	            {
	                FeatureIdentifier = existingFeatureMix.FeatureIdentifier,
	                ModelIdentifier = string.Empty,
	                FdpTakeRateFeatureMixId = existingFeatureMix.FdpTakeRateFeatureMixId,
	                OriginalVolume = existingFeatureMix.Volume,
	                OriginalPercentageTakeRate = existingFeatureMix.PercentageTakeRate,
	                Mode = dataChange.Mode,
	                FdpTakeRateSummaryId = null,
	                Volume = featureMixVolume,
	                PercentageTakeRate = featureMixPercentageTakeRate*100
	            };

                changeset.Changes.Add(featureMixDataChange);
	        }
	    }
	    private void CalculateModelsForMarket()
	    {
	        var models = CurrentData.SummaryItems.Where(s => s.ModelId.HasValue && s.PercentageTakeRate != 0);
	        foreach (var model in models)
	        {
	            var modelVolume = (int) (CurrentDataChange.Volume.GetValueOrDefault()*model.PercentageTakeRate);
	            var modelDataChange = new DataChange(CurrentDataChange)
	            {
	                ModelIdentifier = model.ModelIdentifier,
	                FdpTakeRateSummaryId = model.FdpTakeRateSummaryId,
	                OriginalVolume = model.Volume,
	                OriginalPercentageTakeRate = model.PercentageTakeRate,
	                Volume = modelVolume,
                    PercentageTakeRate = model.PercentageTakeRate * 100,
                    Mode = CurrentDataChange.Mode
	            };
                // If nothing has changed, don't update
	            if (modelDataChange.Volume == model.Volume) continue;

	            CurrentChangeSet.Changes.Add(modelDataChange);

	            CalculateFeaturesForMarketAndModel(model);
	            CalculateFeatureMixesForMarketAndModel(model);
	        }
	    }
	    private void CalculateFeaturesForMarketAndModel(RawTakeRateSummaryItem model)
	    {
	        var modelId = model.ModelId;
            var modelVolume = (int)(CurrentDataChange.Volume.GetValueOrDefault() * model.PercentageTakeRate);
            var features = CurrentData.DataItems.Where(f => f.ModelId == modelId && !f.IsNonApplicableFeatureInGroup && f.PercentageTakeRate != 0);
            
            foreach (var feature in features)
            {
                var featureDataChange = new DataChange(CurrentDataChange)
                {
                    ModelIdentifier = model.ModelIdentifier,
                    FeatureIdentifier = feature.FeatureIdentifier,
                    FdpTakeRateSummaryId = null,
                    FdpVolumeDataItemId = feature.FdpVolumeDataItemId,
                    OriginalVolume = feature.Volume,
                    OriginalPercentageTakeRate = feature.PercentageTakeRate,
                    Volume = (int)(modelVolume * feature.PercentageTakeRate),
                    PercentageTakeRate = feature.PercentageTakeRate * 100,
                    Mode = CurrentDataChange.Mode
                };
                if (featureDataChange.Volume == feature.Volume) continue;
                CurrentChangeSet.Changes.Add(featureDataChange);
            }
	    }
	    private void CalculateFeatureMixesForMarketAndModel(RawTakeRateSummaryItem model)
	    {
            var modelVolume = (int)(CurrentDataChange.Volume.GetValueOrDefault() * model.PercentageTakeRate);
            var featureMixes = CurrentData.FeatureMixItems.Where(f => f.PercentageTakeRate != 0 && f.MarketId == model.MarketId);

            foreach (var featureMix in featureMixes)
            {
                var featureMixDataChange = new DataChange(CurrentDataChange)
                {
                    ModelIdentifier = null,
                    FeatureIdentifier = featureMix.FeatureIdentifier,
                    FdpTakeRateSummaryId = null,
                    FdpTakeRateFeatureMixId = featureMix.FdpTakeRateFeatureMixId,
                    OriginalVolume = featureMix.Volume,
                    OriginalPercentageTakeRate = featureMix.PercentageTakeRate,
                    Volume = (int)(modelVolume * featureMix.PercentageTakeRate),
                    PercentageTakeRate = featureMix.PercentageTakeRate * 100,
                    Mode = CurrentDataChange.Mode
                };
                if (featureMixDataChange.Volume == featureMix.Volume) continue;
                CurrentChangeSet.Changes.Add(featureMixDataChange);
            }
	    }
        private void CalculateFeatureMixesForModel(RawTakeRateSummaryItem model)
        {
            var modelVolume = (int)(CurrentDataChange.Volume.GetValueOrDefault() * model.PercentageTakeRate);
            var featureMixes = CurrentData.FeatureMixItems;

            foreach (var featureMix in featureMixes)
            {
                var featureMixDataChange = new DataChange(CurrentDataChange)
                {
                    ModelIdentifier = null,
                    FeatureIdentifier = featureMix.FeatureIdentifier,
                    FdpTakeRateSummaryId = null,
                    FdpTakeRateFeatureMixId = featureMix.FdpTakeRateFeatureMixId,
                    OriginalVolume = featureMix.Volume,
                    OriginalPercentageTakeRate = featureMix.PercentageTakeRate,
                    Volume = (int)(modelVolume * featureMix.PercentageTakeRate),
                    PercentageTakeRate = featureMix.PercentageTakeRate * 100
                };
                if (featureMixDataChange.Volume == featureMix.Volume) continue;
                CurrentChangeSet.Changes.Add(featureMixDataChange);
            }
        }
	    private void CalculateMarketChange()
	    {
	        var allOtherMarketVolume = CurrentData.TotalVolume;
	        var allMarketVolume = CurrentDataChange.Volume.GetValueOrDefault() + allOtherMarketVolume;
	        var originalVolumeItem = CurrentData.SummaryItems.First(s => !s.ModelId.HasValue);
            
            CurrentDataChange.PercentageTakeRate = (CurrentDataChange.Volume / (decimal)allMarketVolume) * 100;
	        CurrentDataChange.OriginalVolume = originalVolumeItem.Volume;
	        CurrentDataChange.OriginalPercentageTakeRate = originalVolumeItem.Volume/(decimal) (originalVolumeItem.Volume + allOtherMarketVolume);
	        CurrentDataChange.FdpTakeRateSummaryId = originalVolumeItem.FdpTakeRateSummaryId;

            // Need to recompute the total volume for all markets and represent this as a datachange

	        var allMarketsDataChange = new DataChange(CurrentDataChange)
	        {
	            MarketId = null,
	            OriginalVolume = CurrentDataChange.OriginalVolume + allOtherMarketVolume,
	            OriginalPercentageTakeRate = 1,
	            PercentageTakeRate = 100,
	            Volume = allMarketVolume,
                Mode = CurrentDataChange.Mode
	        };

            CurrentChangeSet.Changes.Add(allMarketsDataChange);
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