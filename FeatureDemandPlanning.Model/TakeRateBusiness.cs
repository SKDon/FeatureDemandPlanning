using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using ClosedXML.Excel;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateBusiness
    {
        public FdpChangeset CurrentChangeSet { get; set; }
        public RawTakeRateData CurrentData { get; set; }

        public TakeRateBusiness(IDataContext context, TakeRateParameters forParameters)
        {
            _dataContext = context;
            _filter = TakeRateFilter.FromTakeRateParameters(forParameters);

            
            CurrentChangeSet = forParameters.Changeset;
            if (CurrentChangeSet == null || CurrentChangeSet is EmptyFdpChangeset)
            {
                return;
            }
            CurrentData = _dataContext.TakeRate.GetRawData(_filter).Result;
            _currentDataChange = CurrentChangeSet.Changes.First();
            InitialiseDataForChange();
        }
        public void CalculateChanges()
        {
            if (_currentDataChange.IsFeatureChange)
            {
                BuildFeatureChangeset(_currentDataChange);
            }
            else if (_currentDataChange.IsModelSummary)
            {
                CalculateModelChange();
                CalculatePowertrainChangeForModel();
            }
            else if (_currentDataChange.IsPowertrainChange)
            {
                CalculatePowertrainChange();
            }
            else if (_currentDataChange.IsWholeMarketChange)
            {
                CalculateMarketChange();
                CalculatePowertrainChangeForMarket();
                CalculateModelsForMarket();
                CalculateFeaturesForMarket();
                CalculateFeatureMixesForMarket();
            }
            
            RemoveUnchangedItemsFromChangeset();
            UpdateDataFromChangeset();
        }
        public XLWorkbook ExportChangeset()
        {
            var changes = _dataContext.TakeRate.GetChangesetHistoryDetailsAsDataTable(_filter).Result;

            var dv = changes.DefaultView;
            dv.Sort = "UpdatedOn";
            changes = dv.ToTable();

            var wb = new XLWorkbook();
            wb.Worksheets.Add(changes);
            wb.Worksheets.First().Column(5).CellsUsed().Style.NumberFormat.NumberFormatId = 10;
            wb.Worksheets.First().Column(6).CellsUsed().Style.NumberFormat.NumberFormatId = 10;
            wb.Worksheets.First().Column(7).CellsUsed().Style.NumberFormat.NumberFormatId = 3;
            wb.Worksheets.First().Column(8).CellsUsed().Style.NumberFormat.NumberFormatId = 3;

            return wb;
        }
        public void SaveChangeset()
        {
            _dataContext.TakeRate.SaveChangeset(_filter, CurrentChangeSet);
        }
        public void ValidateChangeset()
        {
            var validationResults = Validator.Validate(CurrentData);

            Validator.Persist(_dataContext, _filter, validationResults);
        }

        #region "Private Methods"

        private void InitialiseDataForChange()
        {
            _currentDataChange = CurrentChangeSet.Changes.First();
            _currentModelId = _currentDataChange.GetModelId().GetValueOrDefault();
            _currentModelVolumes = CurrentData.SummaryItems.Where(s => s.ModelId.HasValue).Sum(s => s.Volume);
            _currentModelVolume = GetModelVolume(_currentModelId);

            _existingFeature =
                CurrentData.DataItems.FirstOrDefault(
                    d => _currentDataChange.IsMatchingModel(d) && _currentDataChange.IsMatchingFeature(d));
        }
        private void UpdateDataFromChangeset()
        {
            Parallel.ForEach(CurrentChangeSet.Changes, (change) =>
            {
                UpdateFeatureDataFromChange(change);
                UpdateModelDataFromChange(change);
                UpdateFeatureMixDataFromChange(change);
                UpdatePowertrainDataFromChange(change);
                UpdateMarketDataFromChange(change);
                UpdateAllMarketDataFromChange(change);
            });
        }
        private void UpdateFeatureDataFromChange(DataChange featureChange)
        {
            if (!featureChange.IsFeatureChange) return;

            var dataToUpdate = CurrentData.DataItems.FirstOrDefault(d => d.FdpVolumeDataItemId == featureChange.FdpVolumeDataItemId);

            if (dataToUpdate == null) return;

            dataToUpdate.PercentageTakeRate = featureChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            dataToUpdate.Volume = featureChange.Volume.GetValueOrDefault();
        }
        private void UpdateModelDataFromChange(DataChange modelChange)
        {
            if (!modelChange.IsModelSummary) return;

            var dataToUpdate = CurrentData.SummaryItems.FirstOrDefault(d => d.FdpTakeRateSummaryId == modelChange.FdpTakeRateSummaryId);

            if (dataToUpdate == null) return;

            dataToUpdate.PercentageTakeRate = modelChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            dataToUpdate.Volume = modelChange.Volume.GetValueOrDefault();
        }
        private void UpdateFeatureMixDataFromChange(DataChange featureMixChange)
        {
            if (!featureMixChange.IsFeatureSummary) return;

            var dataToUpdate = CurrentData.FeatureMixItems.First(d => d.FdpTakeRateFeatureMixId == featureMixChange.FdpTakeRateFeatureMixId);

            if (dataToUpdate == null) return;

            dataToUpdate.PercentageTakeRate = featureMixChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            dataToUpdate.Volume = featureMixChange.Volume.GetValueOrDefault();
        }
        private void UpdatePowertrainDataFromChange(DataChange powertrainChange)
        {
            if (!powertrainChange.IsPowertrainChange) return;

            var dataToUpdate = CurrentData.PowertrainDataItems.First(d => d.FdpPowertrainDataItemId == powertrainChange.FdpPowertrainDataItemId);

            if (dataToUpdate == null) return;

            dataToUpdate.PercentageTakeRate = powertrainChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            dataToUpdate.Volume = powertrainChange.Volume.GetValueOrDefault();
        }
        private void UpdateMarketDataFromChange(DataChange marketChange)
        {
            if (!marketChange.IsWholeMarketChange) return;

            var dataToUpdate = CurrentData.SummaryItems.First(d => d.FdpTakeRateSummaryId == marketChange.FdpTakeRateSummaryId);

            if (dataToUpdate == null) return;

            dataToUpdate.PercentageTakeRate = marketChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            dataToUpdate.Volume = marketChange.Volume.GetValueOrDefault();
        }
        private void UpdateAllMarketDataFromChange(DataChange marketChange)
        {
            if (!marketChange.IsAllMarketChange) return;

            CurrentData.TotalVolume = marketChange.Volume.GetValueOrDefault();
        }
        private void BuildFeatureChangeset(DataChange fromChange)
        {
            var featureChange = CalculateFeatureChange(fromChange);
            if (featureChange == null || !featureChange.HasChanged) return;

            var featureMixChange = CalculateFeatureMixChange(featureChange);
            if (featureMixChange != null)
            {
                CurrentChangeSet.Changes.Add(featureMixChange);
            }

            var standardFeatureChanges = CalculateStandardFeatureChange(featureChange);
            if (standardFeatureChanges.Any())
            {
                foreach (var standardFeatureChange in standardFeatureChanges)
                {
                    CurrentChangeSet.Changes.Add(standardFeatureChange);

                    var standardFeatureMixChange = CalculateFeatureMixChange(standardFeatureChange);
                    if (standardFeatureMixChange != null)
                    {
                        CurrentChangeSet.Changes.Add(standardFeatureMixChange);
                    }
                }
            }

            CurrentChangeSet.Changes.AddRange(CalculatePackFromFeature(featureChange));
            CurrentChangeSet.Changes.AddRange(CalculateFeaturesFromPack(featureChange));
        }
        private IEnumerable<DataChange> CalculateStandardFeatureChange(DataChange fromChange)
        {
            var standardFeatureDataChanges = new List<DataChange>();

            // If this is a feature within an exclusive feature group and not the standard feature, recalculate the percentage take and volume
            // standard feature as the model volume less the volume of any options in the group

            var feature =
                CurrentData.DataItems.FirstOrDefault(
                    f => f.FeatureId == fromChange.GetFeatureId() && f.ModelId == fromChange.GetModelId());

            if (feature == null) return standardFeatureDataChanges;

            var efgItems =
                CurrentData.DataItems.Where(
                    g =>
                        fromChange.IsMatchingModel(g) &&
                        g.ExclusiveFeatureGroup == feature.ExclusiveFeatureGroup).ToList();

            var optionalFeatures = efgItems.Where(g => !g.IsStandardFeatureInGroup && !g.IsUncodedFeature).ToList();
            var standardFeatures = efgItems.Where(g => g.IsStandardFeatureInGroup && g.FeatureId != _existingFeature.FeatureId && !g.IsUncodedFeature).ToList();

            if (!optionalFeatures.Any() || !standardFeatures.Any()) return standardFeatureDataChanges;

            var optionalFeaturePercentageTakeRate =
                optionalFeatures.Where(o => o.FeatureIdentifier != fromChange.FeatureIdentifier)
                    .Sum(o => o.PercentageTakeRate) + fromChange.PercentageTakeRateAsFraction.GetValueOrDefault();

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
                standardFeatureVolume = _currentModelVolume;
            }
            else if (standardFeaturePercentageTakeRate > 0)
            {
                standardFeatureVolume = (int)Math.Round(_currentModelVolume * standardFeaturePercentageTakeRate);
            }

            // Whilst an error in the OXO, we may have more than 1 standard feature in a group
            // We need to apportion the take rate and volume between them
            if (standardFeatures.Count() > 1)
            {
                standardFeatureVolume = (int)Math.Round(standardFeatureVolume/(decimal)standardFeatures.Count());
                standardFeaturePercentageTakeRate = standardFeaturePercentageTakeRate/standardFeatures.Count();
            }

            foreach (var standardFeature in standardFeatures)
            {
                var standardFeatureDataChange = new DataChange(fromChange)
                {
                    FeatureIdentifier = "O" + standardFeature.FeatureId,
                    Volume = standardFeatureVolume,
                    PercentageTakeRate = standardFeaturePercentageTakeRate*100,
                    // Make sure we use the id of the standard feature item, not the original data change item
                    FdpVolumeDataItemId =
                        standardFeature.FdpVolumeDataItemId == 0 ? (int?) null : standardFeature.FdpVolumeDataItemId,
                    Mode = _currentDataChange.Mode,
                    OriginalPercentageTakeRate = standardFeature.PercentageTakeRate,
                    OriginalVolume = standardFeature.Volume
                };

                standardFeatureDataChanges.Add(standardFeatureDataChange);
            }

            return standardFeatureDataChanges;
        }
        private DataChange CalculateFeatureMixChange(DataChange fromChange)
        {
            if (fromChange == null) return null;

            var existingFeatureVolumes =
                CurrentData.DataItems.Where(
                    d => !fromChange.IsMatchingModel(d) && fromChange.IsMatchingFeature(d))
                    .Sum(d => d.Volume);

            var featureMixPercentageTakeRate = (existingFeatureVolumes +
                                                        fromChange.Volume.GetValueOrDefault()) /
                                                       (decimal)_currentModelVolumes;
            var featureMixVolume = 0;
            var existingFeatureMix =
                CurrentData.FeatureMixItems.FirstOrDefault(fromChange.IsMatchingFeatureMix);

            if (featureMixPercentageTakeRate > 1)
            {
                featureMixPercentageTakeRate = 1;
            }
            if (featureMixPercentageTakeRate < 0)
            {
                featureMixPercentageTakeRate = 0;
            }

            if (featureMixPercentageTakeRate > 0)
            {
                if (featureMixPercentageTakeRate == 1)
                {
                    featureMixVolume = _currentModelVolumes;
                }
                else
                {
                    featureMixVolume = (int)Math.Round(_currentModelVolumes * featureMixPercentageTakeRate);
                }
            }

            var featureMixDataChange = new DataChange(fromChange)
            {
                PercentageTakeRate = featureMixPercentageTakeRate * 100,
                Volume = featureMixVolume,
                ModelIdentifier = string.Empty,
                FdpVolumeDataItemId = null,
                FdpTakeRateFeatureMixId =
                    existingFeatureMix == null
                        ? (int?)null
                        : existingFeatureMix.FdpTakeRateFeatureMixId,
                Mode = _currentDataChange.Mode,
                OriginalPercentageTakeRate = 
                    existingFeatureMix == null 
                        ? 0 
                        : existingFeatureMix.PercentageTakeRate,
                OriginalVolume = 
                    existingFeatureMix == null
                        ? 0
                        : existingFeatureMix.Volume
            };
            return featureMixDataChange;
        }

        public List<T> IntersectAll<T>(IEnumerable<IEnumerable<T>> lists)
        {
            if (!lists.Any())
            {
                return new List<T>();
            }
            var hashSet = new HashSet<T>(lists.First());
            foreach (var list in lists.Skip(1))
            {
                hashSet.IntersectWith(list);
            }
            return hashSet.ToList();
        }
        private IEnumerable<DataChange> CalculatePackFromFeature(DataChange fromChange)
        {
            var packChanges = new List<DataChange>();

            // If this is an optional feature and can have a take rate independant of the feature packs (but not less)
            // Then do not update the other features
            // Also, if this is an uncoded feature, do not change anything else

            if (!fromChange.IsFeatureChange || fromChange.IsFeaturePack || _existingFeature.IsOptionalFeatureInGroup || _existingFeature.IsUncodedFeature)
            {
                return packChanges;
            }

            // Get all the packs to which the feature being updated belongs

            var allPacks = CurrentData.FeaturePacks.Where(p => p.ModelId == fromChange.GetModelId() &&
                                                               p.PackItems.Any(
                                                                   f => f.FeatureId == fromChange.GetFeatureId())).ToList();

            // If the feature belongs to multiple packs, we are not safe to update the individual pack items
            if (allPacks.Count() != 1) return packChanges;

            // Get only those features common to all packs, as updating others may cause unexpected results
            // Do not do anything with the original updated feature here

            var allFeaturesIdentifiers = allPacks
                .Select(pack => pack.DataItems.Where(d => d.FeatureId.HasValue)
                .Select(d => d.FeatureId.Value).ToList()).ToList();

            var commonFeatureIdentifiers = IntersectAll(allFeaturesIdentifiers);
            var commonFeatures = CurrentData.DataItems
                .Where(d => d.ModelId == fromChange.GetModelId() &&
                            d.FeatureId.GetValueOrDefault() != fromChange.GetFeatureId() &&
                            commonFeatureIdentifiers.Contains(d.FeatureId.GetValueOrDefault()) &&
                            !d.OxoCode.Contains("S") &&
                            !d.OxoCode.Contains("NA") &&
                            !d.OxoCode.Contains("O") &&
                            !d.IsUncodedFeature).ToList();

            // Make sure the pack itself is also in the list
            var parentPack = allPacks.First();
            var packFeature =
                CurrentData.DataItems.FirstOrDefault(p => !p.FeatureId.HasValue && p.FeaturePackId == parentPack.FeaturePackId && p.ModelId == fromChange.GetModelId());

            commonFeatures.Add(packFeature);

            Parallel.ForEach(commonFeatures,
                () => new List<DataChange>(),
                (commonFeature, state, localList) =>
                {
                    var commonFeatureDataChange = CalculateSiblingFromFeatureChange(commonFeature, fromChange);
                    if (commonFeatureDataChange == null || !commonFeatureDataChange.HasChanged) return localList;
                    
                    localList.Add(commonFeatureDataChange);
                    localList.AddRange(CalculateChildDataChanges(commonFeatureDataChange));
                    
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) return;

                    lock (_sync)
                    {
                        packChanges.AddRange(finalResult);
                    }
                });

            return packChanges;
        }
        private DataChange CalculateSiblingFromFeatureChange(RawTakeRateDataItem siblingItem, DataChange fromChange)
        {
            var takeRate = fromChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            var volume = fromChange.Volume;

            if (takeRate > 1)
            {
                // If the take combined pack take rate takes us over 100%, this is an error as a take for a feature can never be more than 100%

                takeRate = 1;
                volume = _currentModelVolume;
            }

            if (siblingItem.OxoCode.Contains("O") &&
                siblingItem.PercentageTakeRate > takeRate)
            {
                // If this is an optional feature and the take rate is currently greater than the combined pack take rate, keep it as is
                // This is because whilst it is part of a pack, it can also be chosen outside of the pack and therefore the take will be greater
                // If the take rate is less than the combined take for the packs, update as otherwise this would be an error

                return null;
            }

            var siblingDataChange = new DataChange(fromChange)
            {
                FdpVolumeDataItemId = siblingItem.FdpVolumeDataItemId,
                Volume = volume,
                PercentageTakeRate = takeRate * 100,
                Mode = fromChange.Mode,
                OriginalPercentageTakeRate = siblingItem.PercentageTakeRate,
                OriginalVolume = siblingItem.Volume,
                FeatureIdentifier = siblingItem.FeatureIdentifier
            };

            // Ensure the change is not > 100%
            if (!(siblingDataChange.PercentageTakeRateAsFraction > 1)) return siblingDataChange;
            
            siblingDataChange.PercentageTakeRate = 100;
            siblingDataChange.Volume = _currentModelVolume;

            return siblingDataChange;
        }
        private DataChange CalculateFeatureFromPack(RawTakeRateDataItem packItem, DataChange fromChange)
        {
            var takeRate = fromChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            var volume = fromChange.Volume;
            var otherPacks = CurrentData.FeaturePacks.Where(p => p.FeaturePackId != fromChange.GetFeatureId() &&
                                                                 p.ModelId == fromChange.GetModelId() &&
                                                                 p.PackItems.Any(
                                                                     f =>
                                                                         f.FeatureId ==
                                                                         packItem.FeatureId.GetValueOrDefault()))
                .ToList();

            if (otherPacks.Any())
            {
                // Does this feature live in more than 1 pack? If so, we need to aggregate the take rate of all the packs up to 100%

                takeRate += otherPacks.Sum(p => p.PackPercentageTakeRate);
                volume += otherPacks.Sum(p => p.PackVolume);
            }

            if (takeRate > 1)
            {
                // If the take combined pack take rate takes us over 100%, this is an error as a take for a feature can never be more than 100%

                takeRate = 1;
                volume = _currentModelVolume;
            }

            if (packItem.OxoCode.Contains("O") &&
                packItem.PercentageTakeRate > takeRate)
            {
                // If this is an optional feature and the take rate is currently greater than the combined pack take rate, keep it as is
                // This is because whilst it is part of a pack, it can also be chosen outside of the pack and therefore the take will be greater
                // If the take rate is less than the combined take for the packs, update as otherwise this would be an error

                return null;
            }

            var featureDataChange = new DataChange(fromChange)
            {
                FdpVolumeDataItemId = packItem.FdpVolumeDataItemId,
                Volume = volume,
                PercentageTakeRate = takeRate * 100,
                Mode = _currentDataChange.Mode,
                OriginalPercentageTakeRate = packItem.PercentageTakeRate,
                OriginalVolume = packItem.Volume,
                FeatureIdentifier = packItem.FeatureIdentifier
            };

            // Ensure the change is not > 100%
            if (!(featureDataChange.PercentageTakeRateAsFraction > 1)) return featureDataChange;
            
            featureDataChange.PercentageTakeRate = 100;
            featureDataChange.Volume = _currentModelVolume;

            return featureDataChange;
        }
        /// <summary>
        /// Calculates the take rate of any features contained in a feature pack data change
        /// </summary>
        private IEnumerable<DataChange> CalculateFeaturesFromPack(DataChange fromChange)
        {
            var featureDataChanges = new List<DataChange>();

            if (!fromChange.IsFeatureChange || !fromChange.IsFeaturePack)
            {
                return featureDataChanges;
            }

            var pack =
                CurrentData.FeaturePacks.First(
                    p =>
                        p.ModelId == _currentDataChange.GetModelId() &&
                        p.FeaturePackId == _currentDataChange.GetFeatureId());

            // Ignore non-applicable features, standard features (these will always be 100% or 0% respectively)
            // Also ignore optional features that can be chosen outside of the pack, the take rate is computed seperately to the pack
            
            var packItems =
                pack.DataItems
                    .Where(d => d.FeatureId.HasValue &&
                                !d.OxoCode.Contains("S") &&
                                !d.OxoCode.Contains("NA") &&
                                !d.OxoCode.Contains("O") &&
                                !d.IsUncodedFeature);

            Parallel.ForEach(packItems,
                () => new List<DataChange>(),
                (packItem, state, localList) =>
                {
                    var featureDataChange = CalculateFeatureFromPack(packItem, fromChange);
                    if (featureDataChange == null)
                        return localList;

                    if (featureDataChange.HasChanged)
                        localList.Add(featureDataChange);

                    localList.AddRange(CalculateChildDataChanges(featureDataChange));

                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) return;

                    lock (_sync) featureDataChanges.AddRange(finalResult);
                });

            return featureDataChanges;
        }
        private IEnumerable<DataChange> CalculateChildDataChanges(DataChange fromChange)
        {
            var childChanges = new List<DataChange>();

            var featureMixDataChange = CalculateFeatureMixChange(fromChange);
            if (featureMixDataChange.HasChanged)
                childChanges.Add(featureMixDataChange);

            var standardFeatureDataChanges = CalculateStandardFeatureChange(fromChange);

            foreach (var standardFeatureDataChange in standardFeatureDataChanges)
            {
                if (!standardFeatureDataChange.HasChanged) continue;

                childChanges.Add(standardFeatureDataChange);

                var standardFeatureMixDataChange = CalculateFeatureMixChange(standardFeatureDataChange);
                if (standardFeatureMixDataChange != null && standardFeatureMixDataChange.HasChanged)
                {
                    childChanges.Add(standardFeatureMixDataChange);
                }
            }

            return childChanges;
        }
        // For a feature change, we simply re-compute the % take if the volume has been altered and vice versa
        // The feature mix will then need to be recalculated
        private DataChange CalculateFeatureChange(DataChange fromChange)
        {
            switch (fromChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    if (fromChange.Is100PercentChange)
                    {
                        fromChange.Volume = _currentModelVolume;
                    }
                    else
                    {
                        fromChange.Volume =
                        (int)Math.Round(_currentModelVolume * fromChange.PercentageTakeRateAsFraction.GetValueOrDefault());
                    }
                    break;
                case TakeRateResultMode.Raw:
                    fromChange.PercentageTakeRate = (fromChange.Volume / (decimal)_currentModelVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // Get the original values

            if (_existingFeature == null) return fromChange;

            fromChange.OriginalPercentageTakeRate = _existingFeature.PercentageTakeRate;
            fromChange.OriginalVolume = _existingFeature.Volume;
            fromChange.FdpVolumeDataItemId = _existingFeature.FdpVolumeDataItemId == 0 ? (int?)null : _existingFeature.FdpVolumeDataItemId;

            return fromChange;
        }
        private int GetModelVolume(int modelId)
        {
            return CurrentData.GetModelVolume(modelId);
        }
        private void CalculatePowertrainChange()
        {
            var marketVolume = CurrentData.SummaryItems.Where(s => string.IsNullOrEmpty(s.ModelIdentifier)).Select(s => s.Volume).FirstOrDefault();

            // Get the original values from raw data
            var existingDerivative = CurrentData.PowertrainDataItems.FirstOrDefault(p => p.DerivativeCode == _currentDataChange.DerivativeCode);

            if (existingDerivative == null) return;

            _currentDataChange.OriginalPercentageTakeRate = existingDerivative.PercentageTakeRate;
            _currentDataChange.OriginalVolume = existingDerivative.Volume;
            _currentDataChange.FdpPowertrainDataItemId = existingDerivative.FdpPowertrainDataItemId;

            if (!_currentDataChange.HasChanged) return;


            var affectedModels = CurrentData.SummaryItems.Where(s => s.DerivativeCode == _currentDataChange.DerivativeCode).ToList();
            var unaffectedModels = CurrentData.SummaryItems.Where(s => !string.IsNullOrEmpty(s.ModelIdentifier) && s.DerivativeCode != _currentDataChange.DerivativeCode && !string.IsNullOrEmpty(s.DerivativeCode)).ToList();

            _currentDataChange.Volume = (int)Math.Round(marketVolume * _currentDataChange.PercentageTakeRateAsFraction.GetValueOrDefault());

            var modelVolume = unaffectedModels.Select(m => m.Volume).Sum() + _currentDataChange.Volume.GetValueOrDefault();

            var numberOfAffectedModels = affectedModels.Count();

            var volumePerModel = _currentDataChange.Volume / numberOfAffectedModels;
            var modelPercentageTakeRate = decimal.Divide(volumePerModel.Value, marketVolume);
            var remainder = _currentDataChange.Volume % numberOfAffectedModels;

            // Update the mix for each of the models under the derivative in question
            // Split the volume and percentage take rate equally amongst all models

            var counter = 0;
           
            Parallel.ForEach(
                affectedModels,
                () => new List<DataChange>(),
                (affectedModel, state, localList) =>
                {
                    var modelDataChange = new DataChange(_currentDataChange)
                    {
                        Volume = volumePerModel,
                        PercentageTakeRate = modelPercentageTakeRate*100,
                        FdpTakeRateSummaryId = affectedModel.FdpTakeRateSummaryId,
                        OriginalVolume = affectedModel.Volume,
                        OriginalPercentageTakeRate = affectedModel.PercentageTakeRate,
                        ModelIdentifier = affectedModel.ModelIdentifier,
                        Mode = _currentDataChange.Mode
                    };

                    if (++counter == numberOfAffectedModels)
                    {
                        modelDataChange.Volume += remainder;
                    }

                    if (modelDataChange.HasChanged)
                    {
                        localList.Add(modelDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) 
                        return;

                    lock (_sync) CurrentChangeSet.Changes.AddRange(finalResult);
                });

            var affectedFeatures =
                CurrentData.DataItems.Where(
                    f => affectedModels.Select(m => m.ModelId.GetValueOrDefault()).Contains(f.ModelId.GetValueOrDefault()) && !f.IsNonApplicableFeatureInGroup).ToList();

            var modelChanges = CurrentChangeSet.Changes.Where(m => m.IsModelSummary).ToList();
            
            Parallel.ForEach(
                affectedFeatures,
                () => new List<DataChange>(),
                (affectedFeature, state, localList) =>
                {
                    var modelDataChange = modelChanges.FirstOrDefault(m => m.IsModelSummary && affectedFeature.ModelId == m.GetModelId());

                    // If the affected model has not been changed, there won't be a changeset entry, therefore we don't need to recompute any of the features

                    if (modelDataChange == null)
                        return null;

                    var featureDataChange = new DataChange(_currentDataChange)
                    {
                        Volume = (int)Math.Round(modelDataChange.Volume.GetValueOrDefault() * affectedFeature.PercentageTakeRate),
                        PercentageTakeRate = affectedFeature.PercentageTakeRate * 100,
                        FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
                        OriginalVolume = affectedFeature.Volume,
                        OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
                        FeatureIdentifier = affectedFeature.FeatureIdentifier,
                        ModelIdentifier = modelDataChange.ModelIdentifier,
                        Mode = _currentDataChange.Mode
                    };

                    if (featureDataChange.HasChanged)
                    {
                        localList.Add(featureDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) 
                        return;

                    lock (_sync) CurrentChangeSet.Changes.AddRange(finalResult);
                });
            
            // Calculate the feature mix changes now that the volumes for the models and features have changed

            var featureChanges = CurrentChangeSet.Changes.Where(f => f.IsFeatureChange).ToList();

            Parallel.ForEach(CurrentData.FeatureMixItems,
                () => new List<DataChange>(),
                (featureMixItem, state, localList) =>
                {
                    var featureMixDataChange = new DataChange(_currentDataChange)
                    {
                        ModelIdentifier = string.Empty,
                        OriginalPercentageTakeRate = featureMixItem.PercentageTakeRate,
                        OriginalVolume = featureMixItem.Volume,
                        FdpTakeRateFeatureMixId = featureMixItem.FdpTakeRateFeatureMixId,
                        FeatureIdentifier = featureMixItem.FeatureIdentifier,
                        Mode = _currentDataChange.Mode
                    };

                    // Get the total volume of the feature for unaffected models

                    var featureVolume = 0;
                    var changedFeatureVolume = 0;

                    featureVolume += CurrentData.DataItems
                        .Where(f => f.FeatureIdentifier == featureMixDataChange.FeatureIdentifier &&
                                    unaffectedModels.Select(m => m.ModelId.GetValueOrDefault())
                                        .Contains(f.ModelId.GetValueOrDefault()))
                        .Select(f => f.Volume)
                        .Sum();

                    // Get the total volume for affected features

                    changedFeatureVolume +=
                        featureChanges.Where(
                            c => c.GetFeatureId() == featureMixDataChange.GetFeatureId())
                            .Select(f => f.Volume.GetValueOrDefault())
                            .Sum();

                    featureMixDataChange.Volume = featureVolume + changedFeatureVolume;
                    featureMixDataChange.PercentageTakeRate =
                        decimal.Divide(featureVolume + changedFeatureVolume, modelVolume) * 100;

                    if (featureMixDataChange.HasChanged)
                    {
                        localList.Add(featureMixDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null)
                        return;

                    lock (_sync) CurrentChangeSet.Changes.AddRange(finalResult); 
                }
            );
        }

        private void CalculateModelChange()
        {
            var marketVolume = CurrentData.SummaryItems.First(s => !s.ModelId.HasValue).Volume;
            var existingModel = CurrentData.SummaryItems.FirstOrDefault(s => _currentDataChange.IsMatchingModel(s));
            var affectedFeatures =
                CurrentData.DataItems.Where(f => _currentDataChange.IsMatchingModel(f) && !f.IsNonApplicableFeatureInGroup);
            var existingModelVolumes = CurrentData.SummaryItems.Where(m => m.ModelId != _currentDataChange.GetModelId() && m.ModelId.HasValue).Sum(m => m.Volume);

            if (existingModel == null) return;

            _currentDataChange.OriginalPercentageTakeRate = existingModel.PercentageTakeRate;
            _currentDataChange.OriginalVolume = existingModel.Volume;
            _currentDataChange.FdpTakeRateSummaryId = existingModel.FdpTakeRateSummaryId;

            if (!_currentDataChange.HasChanged) return;

            switch (_currentDataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    if (_currentDataChange.Is100PercentChange)
                    {
                        _currentDataChange.Volume = marketVolume;
                    }
                    else
                    {
                        _currentDataChange.Volume = (int)Math.Round(marketVolume * decimal.Divide(_currentDataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    }
                    
                    break;
                case TakeRateResultMode.Raw:
                    _currentDataChange.PercentageTakeRate = (_currentDataChange.Volume / (decimal)marketVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // Re-compute all affected features and feature mix

            Parallel.ForEach(affectedFeatures,
                () => new List<DataChange>(),
                (affectedFeature, state, localList) =>
                {
                    var featureDataChange = new DataChange(_currentDataChange)
                    {
                        Volume = (int)Math.Round(_currentDataChange.Volume.GetValueOrDefault() * affectedFeature.PercentageTakeRate),
                        PercentageTakeRate = affectedFeature.PercentageTakeRate * 100,
                        FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
                        OriginalVolume = affectedFeature.Volume,
                        OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
                        FeatureIdentifier = affectedFeature.FeatureIdentifier,
                        FdpTakeRateSummaryId = null,
                        Mode = _currentDataChange.Mode
                    };

                    if (featureDataChange.HasChanged)
                        localList.Add(featureDataChange);

                    var existingFeatureMix =
                        CurrentData.FeatureMixItems.First(f => f.FeatureIdentifier == affectedFeature.FeatureIdentifier);
                    var featureMixVolume =
                        CurrentData.DataItems.Where(d => d.FeatureId == featureDataChange.GetFeatureId() &&
                                                         d.ModelId != _currentDataChange.GetModelId()).Sum(d => d.Volume) +
                        featureDataChange.Volume;
                    var updatedMarketVolume = existingModelVolumes + _currentDataChange.Volume;
                    var featureMixPercentageTakeRate = featureMixVolume / (decimal)updatedMarketVolume;

                    var featureMixDataChange = new DataChange(_currentDataChange)
                    {
                        FeatureIdentifier = existingFeatureMix.FeatureIdentifier,
                        ModelIdentifier = string.Empty,
                        FdpTakeRateFeatureMixId = existingFeatureMix.FdpTakeRateFeatureMixId,
                        OriginalVolume = existingFeatureMix.Volume,
                        OriginalPercentageTakeRate = existingFeatureMix.PercentageTakeRate,
                        Mode = _currentDataChange.Mode,
                        FdpTakeRateSummaryId = null,
                        Volume = featureMixVolume,
                        PercentageTakeRate = featureMixPercentageTakeRate * 100
                    };

                    if (featureMixDataChange.HasChanged)
                        localList.Add(featureMixDataChange);

                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) return;

                    lock (_sync)
                    {
                        CurrentChangeSet.Changes.AddRange(finalResult);
                    }
                });
        }
        private void CalculatePowertrainChangeForModel()
        {
            var model = CurrentData.SummaryItems.First(m => m.ModelId == _currentDataChange.GetModelId());
            var derivative = CurrentData.PowertrainDataItems.First(p => p.DerivativeCode == model.DerivativeCode);
            var otherModels =
                CurrentData.SummaryItems.Where(
                    m => m.DerivativeCode == model.DerivativeCode && m.ModelId != _currentDataChange.GetModelId()).ToList();
            var otherModelVolume = otherModels.Sum(m => m.Volume);
            var otherModelPercentageTakeRate = otherModels.Sum(m => m.PercentageTakeRate);

            var derivativeDataChange = new DataChange(_currentDataChange)
            {
                FdpTakeRateSummaryId = null,
                ModelIdentifier = string.Empty,
                FdpPowertrainDataItemId = derivative.FdpPowertrainDataItemId,
                Mode = _currentDataChange.Mode,
                OriginalPercentageTakeRate = derivative.PercentageTakeRate,
                OriginalVolume = derivative.Volume,
                Volume = otherModelVolume + _currentDataChange.Volume,
                PercentageTakeRate = (otherModelPercentageTakeRate + _currentDataChange.PercentageTakeRateAsFraction) * 100,
                DerivativeCode = derivative.DerivativeCode
            };

            if (derivativeDataChange.HasChanged)
            {
                CurrentChangeSet.Changes.Add(derivativeDataChange);
            }
        }
        private void CalculateModelsForMarket()
        {
            var models = CurrentData.SummaryItems.Where(s => s.ModelId.HasValue && s.PercentageTakeRate != 0).ToList();
            
            Parallel.ForEach(models,
                () => new List<DataChange>(),
                (model, state, localList) =>
                {
                    var modelVolume = (int)(_currentDataChange.Volume.GetValueOrDefault() * model.PercentageTakeRate);
                    var modelDataChange = new DataChange(_currentDataChange)
                    {
                        ModelIdentifier = model.ModelIdentifier,
                        FdpTakeRateSummaryId = model.FdpTakeRateSummaryId,
                        OriginalVolume = model.Volume,
                        OriginalPercentageTakeRate = model.PercentageTakeRate,
                        Volume = modelVolume,
                        PercentageTakeRate = model.PercentageTakeRate * 100,
                        Mode = _currentDataChange.Mode
                    };
                    if (modelDataChange.HasChanged)
                    {
                        localList.Add(modelDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) return;
                    lock (_sync)
                    {
                        CurrentChangeSet.Changes.AddRange(finalResult);
                    }
                });

        }
        private void CalculateFeaturesForMarket()
        {
            var features = CurrentData.DataItems.Where(f => !f.IsNonApplicableFeatureInGroup && f.PercentageTakeRate != 0);

            var modelChanges = CurrentChangeSet.Changes.Where(m => m.IsModelSummary).ToList();

            Parallel.ForEach(features,
                () => new List<DataChange>(),
                (feature, state, localList) =>
                {
                    var modelDataChange =
                            modelChanges.FirstOrDefault(m => feature.ModelId == m.GetModelId());

                    // If the affected model has not been changed, there won't be a changeset entry, therefore we don't need to recompute any of the features

                    if (modelDataChange == null)
                        return localList;

                    var modelVolume = (int)(_currentDataChange.Volume.GetValueOrDefault() * modelDataChange.PercentageTakeRateAsFraction.GetValueOrDefault());
                    var featureDataChange = new DataChange(_currentDataChange)
                    {
                        ModelIdentifier = modelDataChange.ModelIdentifier,
                        FeatureIdentifier = feature.FeatureIdentifier,
                        FdpTakeRateSummaryId = null,
                        FdpVolumeDataItemId = feature.FdpVolumeDataItemId,
                        OriginalVolume = feature.Volume,
                        OriginalPercentageTakeRate = feature.PercentageTakeRate,
                        Volume = (int)(modelVolume * feature.PercentageTakeRate),
                        PercentageTakeRate = feature.PercentageTakeRate * 100,
                        Mode = _currentDataChange.Mode
                    };
                    if (featureDataChange.HasChanged)
                    {
                        localList.Add(featureDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null) return;
                    lock (_sync)
                    {
                        CurrentChangeSet.Changes.AddRange(finalResult);
                    }
                });
        }
        private void CalculatePowertrainChangeForMarket()
        {
            var derivatives = CurrentData.PowertrainDataItems.Where(p => p.PercentageTakeRate != 0);

            Parallel.ForEach(derivatives,
                () => new List<DataChange>(),
                (derivative, state, localList) =>
                {
                    var derivativeVolume =
                        (int) (_currentDataChange.Volume.GetValueOrDefault()*derivative.PercentageTakeRate);
                    var derivativeDataChange = new DataChange(_currentDataChange)
                    {
                        FdpTakeRateSummaryId = null,
                        FdpPowertrainDataItemId = derivative.FdpPowertrainDataItemId,
                        OriginalVolume = derivative.Volume,
                        OriginalPercentageTakeRate = derivative.PercentageTakeRate,
                        Volume = derivativeVolume,
                        PercentageTakeRate = derivative.PercentageTakeRate*100,
                        Mode = _currentDataChange.Mode,
                        DerivativeCode = derivative.DerivativeCode
                    };

                    if (derivativeDataChange.HasChanged)
                    {
                        localList.Add(derivativeDataChange);
                    }
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null)
                        return;

                    lock (_sync)
                    {
                        CurrentChangeSet.Changes.AddRange(finalResult);
                    }
                });
        }
        private void CalculateFeatureMixesForMarket()
        {
            var marketVolume = _currentDataChange.Volume.GetValueOrDefault();
            var featureMixes = CurrentData.FeatureMixItems.Where(f => f.PercentageTakeRate != 0).ToList();

            var featureChanges = CurrentChangeSet.Changes.Where(f => f.IsFeatureChange).ToList();

            Parallel.ForEach(featureMixes,
                () => new List<DataChange>(),
                (featureMix, state, localList) =>
                {
                    var featureMixVolume =
                       featureChanges.Where(c => c.FeatureIdentifier == featureMix.FeatureIdentifier)
                            .Sum(c => c.Volume);

                    var featureMixDataChange = new DataChange(_currentDataChange)
                    {
                        ModelIdentifier = null,
                        FeatureIdentifier = featureMix.FeatureIdentifier,
                        FdpTakeRateSummaryId = null,
                        FdpTakeRateFeatureMixId = featureMix.FdpTakeRateFeatureMixId,
                        OriginalVolume = featureMix.Volume,
                        OriginalPercentageTakeRate = featureMix.PercentageTakeRate,
                        Volume = featureMixVolume,
                        PercentageTakeRate = (featureMixVolume / (decimal)marketVolume) * 100,
                        Mode = _currentDataChange.Mode
                    };

                    localList.Add(featureMixDataChange);
                    return localList;
                },
                (finalResult) =>
                {
                    if (finalResult == null)
                        return;

                    lock (_sync)
                    {
                        CurrentChangeSet.Changes.AddRange(finalResult);
                    }
                });
        }
        private void CalculateMarketChange()
        {
            var allOtherMarketVolume = CurrentData.TotalVolume;
            var allMarketVolume = _currentDataChange.Volume.GetValueOrDefault() + allOtherMarketVolume;
            var originalVolumeItem = CurrentData.SummaryItems.First(s => !s.ModelId.HasValue);

            _currentDataChange.PercentageTakeRate = (_currentDataChange.Volume / (decimal)allMarketVolume) * 100;
            _currentDataChange.OriginalVolume = originalVolumeItem.Volume;
            _currentDataChange.OriginalPercentageTakeRate = originalVolumeItem.Volume / (decimal)(originalVolumeItem.Volume + allOtherMarketVolume);
            _currentDataChange.FdpTakeRateSummaryId = originalVolumeItem.FdpTakeRateSummaryId;

            // Need to recompute the total volume for all markets and represent this as a datachange

            var allMarketsDataChange = new DataChange(_currentDataChange)
            {
                MarketId = null,
                OriginalVolume = _currentDataChange.OriginalVolume + allOtherMarketVolume,
                OriginalPercentageTakeRate = 1,
                PercentageTakeRate = 100,
                Volume = allMarketVolume,
                Mode = _currentDataChange.Mode
            };

            if (allMarketsDataChange.HasChanged)
                CurrentChangeSet.Changes.Add(allMarketsDataChange);
        }
        private void RemoveUnchangedItemsFromChangeset()
        {
            CurrentChangeSet.Changes = CurrentChangeSet.Changes
                    .Where(c => c.HasChanged).ToList();
        }

        #endregion

        #region "Properties"

        private readonly IDataContext _dataContext;
        private readonly TakeRateFilter _filter;

        private int _currentModelId;
        private DataChange _currentDataChange;
        private int _currentModelVolume;
        private int _currentModelVolumes;
        
        private RawTakeRateDataItem _existingFeature;

        private readonly object _sync = new object();

        #endregion
    }
}
