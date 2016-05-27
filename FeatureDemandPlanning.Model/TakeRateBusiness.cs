using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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

            CurrentData = _dataContext.TakeRate.GetRawData(_filter).Result;
            CurrentChangeSet = forParameters.Changeset;
            _currentDataChange = CurrentChangeSet.Changes.First();

            InitialiseDataForChange();
        }

        public FdpChangeset SaveChangeset()
        {
            if (_currentDataChange.IsFeatureChange)
            {
                CalculateFeatureChange();
                CalculateStandardFeatureChange();
                CalculatePackFromFeature();
                CalculateFeaturesFromPack();
            }
            else if (_currentDataChange.IsModelSummary)
            {
                CalculateModelChange();
                CalculatePowertrainChangeForModel();
            }
            else if (_currentDataChange.IsWholeMarketChange)
            {
                CalculateMarketChange();
                CalculatePowertrainChangeForMarket();
                CalculateModelsForMarket();
                CalculateFeatureMixesForMarket();
            }
            else if (_currentDataChange.IsPowertrainChange)
            {
                CalculatePowertrainChange();
            }

            RemoveUnchangedItemsFromChangeset();

            return _dataContext.TakeRate.SaveChangeset(_filter, CurrentChangeSet).Result;
        }

        public async Task ValidateChangeset()
        {
            var rawData = await _dataContext.TakeRate.GetRawData(_filter);
            var validationResults = Validator.Validate(rawData);

            await Validator.Persist(_dataContext, _filter, validationResults);
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
            _existingFeatureVolumes =
                CurrentData.DataItems.Where(
                    d => !_currentDataChange.IsMatchingModel(d) && _currentDataChange.IsMatchingFeature(d))
                    .Sum(d => d.Volume);
            _existingFeatureMix =
                CurrentData.FeatureMixItems.FirstOrDefault(f => _currentDataChange.IsMatchingFeatureMix(f));
        }

        private void CalculateStandardFeatureChange()
        {
            // If this is a feature within an exclusive feature group and not the standard feature, recalculate the percentage take and volume
            // standard feature as the model volume less the volume of any options in the group

            if (_existingFeature == null) return;

            var efgItems =
                CurrentData.DataItems.Where(
                    g =>
                        _currentDataChange.IsMatchingModel(g) &&
                        g.ExclusiveFeatureGroup == _existingFeature.ExclusiveFeatureGroup).ToList();
            var optionalFeatures = efgItems.Where(g => !g.IsStandardFeatureInGroup).ToList();
            var standardFeature = efgItems.FirstOrDefault(g => g.IsStandardFeatureInGroup);

            if (standardFeature == null || !optionalFeatures.Any() ||
                standardFeature.FeatureId == _existingFeature.FeatureId) return;

            var optionalFeaturePercentageTakeRate =
                optionalFeatures.Where(o => o.FeatureIdentifier != _currentDataChange.FeatureIdentifier)
                    .Sum(o => o.PercentageTakeRate) + _currentDataChange.PercentageTakeRateAsFraction.GetValueOrDefault();

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
                standardFeatureVolume = (int)(_currentModelVolume * standardFeaturePercentageTakeRate);
            }
            var standardFeatureDataChange = new DataChange(_currentDataChange)
            {
                FeatureIdentifier = "O" + standardFeature.FeatureId,
                Volume = standardFeatureVolume,
                PercentageTakeRate = standardFeaturePercentageTakeRate * 100,
                // Make sure we use the id of the standard feature item, not the original data change item
                FdpVolumeDataItemId =
                    standardFeature.FdpVolumeDataItemId == 0 ? (int?)null : standardFeature.FdpVolumeDataItemId,
                Mode = _currentDataChange.Mode,
                OriginalPercentageTakeRate = standardFeature.PercentageTakeRate,
                OriginalVolume = standardFeature.Volume
            };
            CurrentChangeSet.Changes.Add(standardFeatureDataChange);

            var existingStandardFeatureVolumes =
                CurrentData.DataItems.Where(
                    d => !standardFeatureDataChange.IsMatchingModel(d) && standardFeatureDataChange.IsMatchingFeature(d))
                    .Sum(d => d.Volume);

            var standardFeatureMixPercentageTakeRate = (existingStandardFeatureVolumes +
                                                        standardFeatureDataChange.Volume.GetValueOrDefault()) /
                                                       (decimal)_currentModelVolumes;
            var standardFeatureMixVolume = 0;
            var existingStandardFeatureMix =
                CurrentData.FeatureMixItems.First(f => standardFeatureDataChange.IsMatchingFeatureMix(f));

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
                standardFeatureMixVolume = _currentModelVolumes;
            }
            else if (standardFeatureMixPercentageTakeRate > 0)
            {
                standardFeatureMixVolume = (int)(_currentModelVolumes * standardFeatureMixPercentageTakeRate);
            }
            var standardFeatureMixDataChange = new DataChange(standardFeatureDataChange)
            {
                PercentageTakeRate = standardFeatureMixPercentageTakeRate * 100,
                Volume = standardFeatureMixVolume,
                ModelIdentifier = string.Empty,
                FdpVolumeDataItemId = null,
                FdpTakeRateFeatureMixId =
                    existingStandardFeatureMix == null
                        ? (int?)null
                        : existingStandardFeatureMix.FdpTakeRateFeatureMixId,
                Mode = _currentDataChange.Mode,
                OriginalPercentageTakeRate = existingStandardFeatureMix.PercentageTakeRate,
                OriginalVolume = existingStandardFeatureMix.Volume
            };
            CurrentChangeSet.Changes.Add(standardFeatureMixDataChange);
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

        private void CalculatePackFromFeature()
        {
            if (!_currentDataChange.IsFeatureChange || _currentDataChange.IsFeaturePack)
            {
                return;
            }

            // If this is an optional feature and can have a take rate independant of the feature packs (but not less)
            // Then do not update the other features

            if (_existingFeature.IsOptionalFeatureInGroup) return;

            // Get all the packs to which the feature being updated belongs

            var allPacks = CurrentData.FeaturePacks.Where(p => p.ModelId == _currentDataChange.GetModelId() &&
                                                               p.PackItems.Any(
                                                                   f => f.FeatureId == _currentDataChange.GetFeatureId())).ToList();
            var packData = allPacks.First().DataItems.First(d => !d.FeatureId.HasValue);

            // If the feature belongs to multiple packs, we are not safe to update the individual pack items
            if (allPacks.Count() != 1) return;

            // Get only those features common to all packs, as updating others may cause unexpected results
            // Do not do anything with the original updated feature here

            var allFeaturesIdentifiers = allPacks
                .Select(pack => pack.DataItems.Where(d => d.FeatureId.HasValue)
                .Select(d => d.FeatureId.Value).ToList()).ToList();

            var commonFeatureIdentifiers = IntersectAll(allFeaturesIdentifiers);
            var commonFeatures = CurrentData.DataItems
                .Where(d => d.ModelId == _currentDataChange.GetModelId() &&
                            d.FeatureId.GetValueOrDefault() != _currentDataChange.GetFeatureId() &&
                            commonFeatureIdentifiers.Contains(d.FeatureId.GetValueOrDefault()) &&
                            !d.OxoCode.Contains("S") &&
                            !d.OxoCode.Contains("NA")).ToList();

            _packDataChanges = new List<DataChange>();

            foreach (var commonFeature in commonFeatures)
            {
                CalculateFeatureFromSibling(commonFeature);
                CalculateFeatureMixFromPack();
            }
            CalculateStandardFeaturesFromPack();
            CalculateFeatureFromSibling(packData);
            CalculateFeatureMixFromPack();
        }

        private void CalculateFeatureFromSibling(RawTakeRateDataItem packItem)
        {
            var takeRate = _currentDataChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            var volume = _currentDataChange.Volume;

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

                return;
            }

            _currentPackDataChange = new DataChange(_currentDataChange)
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
            if (_currentPackDataChange.PercentageTakeRateAsFraction > 1)
            {
                _currentPackDataChange.PercentageTakeRate = 100;
                _currentPackDataChange.Volume = _currentModelVolume;
            }

            CurrentChangeSet.Changes.Add(_currentPackDataChange);
            _packDataChanges.Add(_currentPackDataChange);
        }
        private void CalculateFeatureFromPack(RawTakeRateDataItem packItem)
        {
            var takeRate = _currentDataChange.PercentageTakeRateAsFraction.GetValueOrDefault();
            var volume = _currentDataChange.Volume;
            var otherPacks = CurrentData.FeaturePacks.Where(p => p.FeaturePackId != _currentDataChange.GetFeatureId() &&
                                                                 p.ModelId == _currentDataChange.GetModelId() &&
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

                return;
            }

            _currentPackDataChange = new DataChange(_currentDataChange)
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
            if (_currentPackDataChange.PercentageTakeRateAsFraction > 1)
            {
                _currentPackDataChange.PercentageTakeRate = 100;
                _currentPackDataChange.Volume = _currentModelVolume;
            }

            CurrentChangeSet.Changes.Add(_currentPackDataChange);
            _packDataChanges.Add(_currentPackDataChange);
        }

        private void CalculateFeatureMixFromPack()
        {
            var existingPackFeatureVolumes =
                CurrentData.DataItems.Where(
                    d => !_currentPackDataChange.IsMatchingModel(d) && _currentPackDataChange.IsMatchingFeature(d))
                    .Sum(d => d.Volume);

            var packItemFeatureMixPercentageTakeRate = (existingPackFeatureVolumes +
                                                        _currentPackDataChange.Volume.GetValueOrDefault()) /
                                                       (decimal)_currentModelVolumes;
            var packItemFeatureMixVolume = 0;
            var existingPackItemFeatureMix =
                CurrentData.FeatureMixItems.FirstOrDefault(f => _currentPackDataChange.IsMatchingFeatureMix(f));

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
                packItemFeatureMixVolume = _currentModelVolumes;
            }
            else if (packItemFeatureMixPercentageTakeRate > 0)
            {
                packItemFeatureMixVolume = (int)(_currentModelVolumes * packItemFeatureMixPercentageTakeRate);
            }

            var packFeatureMixDataChange = new DataChange(_currentPackDataChange)
            {
                PercentageTakeRate = packItemFeatureMixPercentageTakeRate * 100,
                Volume = packItemFeatureMixVolume,
                ModelIdentifier = string.Empty,
                FdpVolumeDataItemId = null,
                FdpTakeRateFeatureMixId =
                    existingPackItemFeatureMix == null
                        ? (int?)null
                        : existingPackItemFeatureMix.FdpTakeRateFeatureMixId,
                OriginalVolume = existingPackItemFeatureMix == null ? 0 : existingPackItemFeatureMix.Volume,
                OriginalPercentageTakeRate =
                    existingPackItemFeatureMix == null ? 0 : existingPackItemFeatureMix.PercentageTakeRate
            };

            CurrentChangeSet.Changes.Add(packFeatureMixDataChange);
        }
        private void CalculateStandardFeaturesFromPack()
        {
            foreach (var packDataChange in _packDataChanges)
            {
                _currentDataChange = packDataChange;
                _existingFeature = CurrentData.DataItems.FirstOrDefault(d => _currentDataChange.IsMatchingModel(d) && _currentDataChange.IsMatchingFeature(d));

                CalculateStandardFeatureChange();
            }
        }
        /// <summary>
        /// Calculates the take rate of any features contained in a feature pack data change
        /// </summary>
        private void CalculateFeaturesFromPack()
        {
            if (!_currentDataChange.IsFeatureChange || !_currentDataChange.IsFeaturePack)
            {
                return;
            }

            _packDataChanges = new List<DataChange>();

            var pack =
                CurrentData.FeaturePacks.First(
                    p =>
                        p.ModelId == _currentDataChange.GetModelId() &&
                        p.FeaturePackId == _currentDataChange.GetFeatureId());

            foreach (var packItem in pack.DataItems
                .Where(d => d.FeatureId.HasValue &&
                            !d.OxoCode.Contains("S") &&
                            !d.OxoCode.Contains("NA")))
            {
                CalculateFeatureFromPack(packItem);
                CalculateFeatureMixFromPack();
            }
            CalculateStandardFeaturesFromPack();
        }
        // For a feature change, we simply re-compute the % take if the volume has been altered and vice versa
        // The feature mix will then need to be recalculated
        private void CalculateFeatureChange()
        {
            switch (_currentDataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    _currentDataChange.Volume =
                        (int)(_currentModelVolume * decimal.Divide(_currentDataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    break;
                case TakeRateResultMode.Raw:
                    _currentDataChange.PercentageTakeRate = (_currentDataChange.Volume / (decimal)_currentModelVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // Get the original values

            if (_existingFeature != null)
            {
                _currentDataChange.OriginalPercentageTakeRate = _existingFeature.PercentageTakeRate;
                _currentDataChange.OriginalVolume = _existingFeature.Volume;
                _currentDataChange.FdpVolumeDataItemId = _existingFeature.FdpVolumeDataItemId == 0 ? (int?)null : _existingFeature.FdpVolumeDataItemId;
            }

            // Update the feature mix for the feature in question

            var featureMixDataChange = new DataChange(_currentDataChange)
            {
                PercentageTakeRate = ((_existingFeatureVolumes + _currentDataChange.Volume) / (decimal)_currentModelVolumes) * 100,
                Volume = _existingFeatureVolumes + _currentDataChange.Volume,
                ModelIdentifier = string.Empty,
                Mode = _currentDataChange.Mode
            };
            if (_existingFeatureMix != null)
            {
                featureMixDataChange.OriginalPercentageTakeRate = _existingFeatureMix.PercentageTakeRate;
                featureMixDataChange.OriginalVolume = _existingFeatureMix.Volume;
                featureMixDataChange.FdpVolumeDataItemId = null;
                featureMixDataChange.FdpTakeRateFeatureMixId = _existingFeatureMix.FdpTakeRateFeatureMixId == 0 ? (int?)null : _existingFeatureMix.FdpTakeRateFeatureMixId;
            }
            CurrentChangeSet.Changes.Add(featureMixDataChange);
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
            var affectedModels = CurrentData.SummaryItems.Where(s => s.DerivativeCode == _currentDataChange.DerivativeCode).ToList();
            var unaffectedModels = CurrentData.SummaryItems.Where(s => !string.IsNullOrEmpty(s.ModelIdentifier) && s.DerivativeCode != _currentDataChange.DerivativeCode && !string.IsNullOrEmpty(s.DerivativeCode)).ToList();

            _currentDataChange.Volume = (int)(marketVolume * decimal.Divide(_currentDataChange.PercentageTakeRate.GetValueOrDefault(), 100));

            var modelVolume = unaffectedModels.Select(m => m.Volume).Sum() + _currentDataChange.Volume.GetValueOrDefault();

            var numberOfAffectedModels = affectedModels.Count();

            var volumePerModel = _currentDataChange.Volume / numberOfAffectedModels;
            var modelPercentageTakeRate = decimal.Divide(volumePerModel.Value, marketVolume);
            var remainder = _currentDataChange.Volume % numberOfAffectedModels;


            // Get the original values

            if (existingDerivative != null)
            {
                _currentDataChange.OriginalPercentageTakeRate = existingDerivative.PercentageTakeRate;
                _currentDataChange.OriginalVolume = existingDerivative.Volume;
                _currentDataChange.FdpPowertrainDataItemId = existingDerivative.FdpPowertrainDataItemId;
            }

            // Update the mix for each of the models under the derivative in question
            // Split the volume and percentage take rate equally amongst all models

            var counter = 0;
            foreach (var affectedModel in affectedModels)
            {
                var modelDataChange = new DataChange(_currentDataChange)
                {
                    Volume = volumePerModel,
                    PercentageTakeRate = modelPercentageTakeRate * 100,
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
                if (modelPercentageTakeRate == modelDataChange.OriginalPercentageTakeRate &&
                    modelDataChange.Volume == modelDataChange.OriginalVolume) continue;

                CurrentChangeSet.Changes.Add(modelDataChange);


                var affectedFeatures = CurrentData.DataItems.Where(f => modelDataChange.IsMatchingModel(f) && !f.IsNonApplicableFeatureInGroup).ToList();
                var change = modelDataChange;
                foreach (var featureDataChange in affectedFeatures.Select(affectedFeature => new DataChange(_currentDataChange)
                {
                    Volume = (int)(change.Volume * affectedFeature.PercentageTakeRate),
                    PercentageTakeRate = affectedFeature.PercentageTakeRate * 100,
                    FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
                    OriginalVolume = affectedFeature.Volume,
                    OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
                    FeatureIdentifier = affectedFeature.FeatureIdentifier,
                    ModelIdentifier = change.ModelIdentifier,
                    Mode = _currentDataChange.Mode
                }))
                {
                    //if (featureDataChange.Volume == featureDataChange.OriginalVolume) continue;
                    CurrentChangeSet.Changes.Add(featureDataChange);
                }
            }

            // We need to revise the market volume at this point

            // Calculate the feature mix changes now that the volumes for the models have changed
            foreach (var featureMixDataChange in CurrentData.FeatureMixItems.Select(featureMixItem => new DataChange(_currentDataChange)
            {
                ModelIdentifier = string.Empty,
                OriginalPercentageTakeRate = featureMixItem.PercentageTakeRate,
                OriginalVolume = featureMixItem.Volume,
                FdpTakeRateFeatureMixId = featureMixItem.FdpTakeRateFeatureMixId,
                FeatureIdentifier = featureMixItem.FeatureIdentifier,
                Mode = _currentDataChange.Mode
            }))
            {
                // Get the total volume of the feature for unaffected models

                var featureVolume = 0;
                var changedFeatureVolume = 0;

                featureVolume += CurrentData.DataItems
                    .Where(f => f.FeatureIdentifier == featureMixDataChange.FeatureIdentifier &&
                                unaffectedModels.Select(m => m.ModelId.GetValueOrDefault()).Contains(f.ModelId.GetValueOrDefault()))
                    .Select(f => f.Volume)
                    .Sum();

                // Get the total volume for affected features

                changedFeatureVolume +=
                    CurrentChangeSet.Changes.Where(c => c.FeatureIdentifier == featureMixDataChange.FeatureIdentifier && c.IsFeatureChange)
                        .Select(f => f.Volume.GetValueOrDefault())
                        .Sum();

                featureMixDataChange.Volume = featureVolume + changedFeatureVolume;
                featureMixDataChange.PercentageTakeRate = decimal.Divide(featureVolume + changedFeatureVolume, modelVolume) * 100;

                if (featureMixDataChange.Volume != featureMixDataChange.OriginalVolume.GetValueOrDefault() ||
                    featureMixDataChange.PercentageTakeRate != featureMixDataChange.OriginalPercentageTakeRate)
                {
                    CurrentChangeSet.Changes.Add(featureMixDataChange);
                }
            }
        }

        private void CalculateModelChange()
        {
            var marketVolume = CurrentData.SummaryItems.First(s => !s.ModelId.HasValue).Volume;
            var existingModel = CurrentData.SummaryItems.FirstOrDefault(s => _currentDataChange.IsMatchingModel(s));
            var affectedFeatures =
                CurrentData.DataItems.Where(f => _currentDataChange.IsMatchingModel(f) && !f.IsNonApplicableFeatureInGroup);
            var existingModelVolumes = CurrentData.SummaryItems.Where(m => m.ModelId != _currentDataChange.GetModelId() && m.ModelId.HasValue).Sum(m => m.Volume);

            switch (_currentDataChange.Mode)
            {
                case TakeRateResultMode.PercentageTakeRate:
                    _currentDataChange.Volume = (int)(marketVolume * decimal.Divide(_currentDataChange.PercentageTakeRate.GetValueOrDefault(), 100));
                    break;
                case TakeRateResultMode.Raw:
                    _currentDataChange.PercentageTakeRate = (_currentDataChange.Volume / (decimal)marketVolume) * 100;
                    break;
                case TakeRateResultMode.NotSet:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            if (existingModel != null)
            {
                _currentDataChange.OriginalPercentageTakeRate = existingModel.PercentageTakeRate;
                _currentDataChange.OriginalVolume = existingModel.Volume;
                _currentDataChange.FdpTakeRateSummaryId = existingModel.FdpTakeRateSummaryId;
            }

            // Re-compute all affected features and feature mix

            foreach (var affectedFeature in affectedFeatures)
            {
                var volume = (int)(_currentDataChange.Volume * affectedFeature.PercentageTakeRate);
                if (volume == affectedFeature.Volume) continue;

                var featureDataChange = new DataChange(_currentDataChange)
                {
                    Volume = (int)(_currentDataChange.Volume * affectedFeature.PercentageTakeRate),
                    PercentageTakeRate = affectedFeature.PercentageTakeRate * 100,
                    FdpVolumeDataItemId = affectedFeature.FdpVolumeDataItemId,
                    OriginalVolume = affectedFeature.Volume,
                    OriginalPercentageTakeRate = affectedFeature.PercentageTakeRate,
                    FeatureIdentifier = affectedFeature.FeatureIdentifier,
                    FdpTakeRateSummaryId = null,
                    Mode = _currentDataChange.Mode
                };

                CurrentChangeSet.Changes.Add(featureDataChange);

                var existingFeatureMix =
                    CurrentData.FeatureMixItems.First(f => f.FeatureIdentifier == affectedFeature.FeatureIdentifier);
                var featureMixVolume =
                    CurrentData.DataItems.Where(d => d.FeatureId == _currentDataChange.GetFeatureId() &&
                        d.ModelId != _currentDataChange.GetModelId()).Sum(d => d.Volume) + featureDataChange.Volume;
                var updatedMarketVolume = existingModelVolumes + _currentDataChange.Volume;
                var featureMixPercentageTakeRate = featureMixVolume / (decimal)updatedMarketVolume;

                if (existingFeatureMix.Volume == featureMixVolume &&
                    existingFeatureMix.PercentageTakeRate == featureMixPercentageTakeRate) continue;

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

                CurrentChangeSet.Changes.Add(featureMixDataChange);
            }
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

            CurrentChangeSet.Changes.Add(derivativeDataChange);
        }
        private void CalculateModelsForMarket()
        {
            var models = CurrentData.SummaryItems.Where(s => s.ModelId.HasValue && s.PercentageTakeRate != 0);
            foreach (var model in models)
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
                CurrentChangeSet.Changes.Add(modelDataChange);

                CalculateFeaturesForMarketAndModel(model);
            }
        }
        private void CalculateFeaturesForMarketAndModel(RawTakeRateSummaryItem model)
        {
            var modelId = model.ModelId;
            var modelVolume = (int)(_currentDataChange.Volume.GetValueOrDefault() * model.PercentageTakeRate);
            var features = CurrentData.DataItems.Where(f => f.ModelId == modelId && !f.IsNonApplicableFeatureInGroup && f.PercentageTakeRate != 0);

            foreach (var feature in features)
            {
                var featureDataChange = new DataChange(_currentDataChange)
                {
                    ModelIdentifier = model.ModelIdentifier,
                    FeatureIdentifier = feature.FeatureIdentifier,
                    FdpTakeRateSummaryId = null,
                    FdpVolumeDataItemId = feature.FdpVolumeDataItemId,
                    OriginalVolume = feature.Volume,
                    OriginalPercentageTakeRate = feature.PercentageTakeRate,
                    Volume = (int)(modelVolume * feature.PercentageTakeRate),
                    PercentageTakeRate = feature.PercentageTakeRate * 100,
                    Mode = _currentDataChange.Mode
                };
                CurrentChangeSet.Changes.Add(featureDataChange);
            }
        }
        private void CalculatePowertrainChangeForMarket()
        {
            var derivatives = CurrentData.PowertrainDataItems.Where(p => p.PercentageTakeRate != 0);
            foreach (var derivative in derivatives)
            {
                var derivativeVolume = (int)(_currentDataChange.Volume.GetValueOrDefault() * derivative.PercentageTakeRate);
                var derivativeDataChange = new DataChange(_currentDataChange)
                {
                    FdpTakeRateSummaryId = null,
                    FdpPowertrainDataItemId = derivative.FdpPowertrainDataItemId,
                    OriginalVolume = derivative.Volume,
                    OriginalPercentageTakeRate = derivative.PercentageTakeRate,
                    Volume = derivativeVolume,
                    PercentageTakeRate = derivative.PercentageTakeRate * 100,
                    Mode = _currentDataChange.Mode,
                    DerivativeCode = derivative.DerivativeCode
                };
                CurrentChangeSet.Changes.Add(derivativeDataChange);
            }
        }
        private void CalculateFeatureMixesForMarket()
        {
            var marketVolume = _currentDataChange.Volume.GetValueOrDefault();
            var featureMixes = CurrentData.FeatureMixItems.Where(f => f.PercentageTakeRate != 0).ToList();

            foreach (var featureMix in featureMixes)
            {
                var featureMixVolume =
                    CurrentChangeSet.Changes.Where(
                        c => c.IsFeatureChange && c.FeatureIdentifier == featureMix.FeatureIdentifier)
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
                CurrentChangeSet.Changes.Add(featureMixDataChange);
            }
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

            CurrentChangeSet.Changes.Add(allMarketsDataChange);
        }
        private void RemoveUnchangedItemsFromChangeset()
        {
            CurrentChangeSet.Changes = CurrentChangeSet.Changes
                .Where(c => c.Volume.GetValueOrDefault() != c.OriginalVolume || c.PercentageTakeRateAsFraction.GetValueOrDefault() != c.OriginalPercentageTakeRate)
                .ToList();
        }

        #endregion

        #region "Properties"

        private readonly IDataContext _dataContext;
        private readonly TakeRateFilter _filter;

        private int _currentModelId;
        private DataChange _currentDataChange;
        private DataChange _currentPackDataChange;
        private int _currentModelVolume;
        private int _currentModelVolumes;
        private IList<DataChange> _packDataChanges;

        private RawTakeRateDataItem _existingFeature;
        private int _existingFeatureVolumes;
        private RawTakeRateFeatureMixItem _existingFeatureMix;

        #endregion
    }
}
