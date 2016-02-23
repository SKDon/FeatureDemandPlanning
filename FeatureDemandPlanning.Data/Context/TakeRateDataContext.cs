using System;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Validators;
using log4net.Config;

namespace FeatureDemandPlanning.DataStore
{
    public class TakeRateDataContext : BaseDataContext, ITakeRateDataContext
    {
        #region "Constructors"

        public TakeRateDataContext(string cdsId) : base(cdsId)
        {
            _documentDataStore = new OXODocDataStore(cdsId);
            _takeRateDataStore = new TakeRateDataStore(cdsId);
            _marketGroupDataStore = new MarketGroupDataStore(cdsId);
            _programmeDataStore = new ProgrammeDataStore(cdsId);
        }

        #endregion

        #region "Public Methods"

        public async Task<IEnumerable<MarketGroup>> ListAvailableMarketGroups(TakeRateFilter filter)
        {
            return await Task.FromResult(_marketGroupDataStore.FdpMarketGroupGetMany(filter));
        }
        public async Task<PagedResults<TakeRateSummary>> ListTakeRateDocuments(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpTakeRateHeaderGetManyByUsername(filter));
        }
        public async Task<PagedResults<TakeRateSummary>> ListLatestTakeRateDocuments()
        {
            var documents = await ListTakeRateDocuments(new TakeRateFilter());
            documents.CurrentPage = documents.CurrentPage.Take(2);
            return documents;
        }
        public async Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses()
        {
            return await Task.FromResult(_takeRateDataStore.FdpTakeRateStatusGetMany());
        }
        public async Task<TakeRateSummary> GetTakeRateDocumentHeader(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpTakeRateHeaderGet(filter));
        }
        public async Task<ITakeRateDocument> GetTakeRateDocument(TakeRateFilter filter)
        {
            return await Task.FromResult(TakeRateDocument.FromFilter(filter));
        }
        public async Task<TakeRateData> GetTakeRateDocumentData(TakeRateFilter filter)
        {
            if (!IsFilterValidForTakeRateData(filter))
                return new TakeRateData();

            return await Task.FromResult(_takeRateDataStore.TakeRateDataItemList(filter));
        }
        public async Task<TakeRateDataItem> GetDataItem(TakeRateFilter filter)
        {
            if (filter.FeatureId.HasValue || filter.FdpFeatureId.HasValue)
            {
                return await Task.FromResult(_takeRateDataStore.TakeRateDataItemGet(filter));
            }
            if (filter.ModelId.HasValue || filter.FdpModelId.HasValue)
            {
                return await Task.FromResult(_takeRateDataStore.TakeRateModelSummaryItemGet(filter));
            }
            return new EmptyTakeRateDataItem();
        }
        public async Task<IEnumerable<TakeRateDataItemNote>> ListDataItemNotes(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.TakeRateDataItemNoteGetMany(filter));
        }
        public async Task<TakeRateDocumentHeader> SaveTakeRateDocumentHeader(TakeRateDocumentHeader headerToSave)
        {
            return await Task.FromResult(_takeRateDataStore.FdpVolumeHeaderSave(headerToSave));
        }
        public async Task<TakeRateDataItem> SaveDataItem(TakeRateDataItem dataItemToSave)
        {
            return await Task.FromResult(_takeRateDataStore.TakeRateDataItemSave(dataItemToSave));
        }
        public async Task<OXODoc> GetUnderlyingOxoDocument(TakeRateFilter filter)
        {
            OXODoc document = new EmptyOxoDocument();
            if (!filter.DocumentId.HasValue)
            {
                var summary = _takeRateDataStore.FdpTakeRateHeaderGet(filter);
                document = _documentDataStore.OXODocGet(summary.OxoDocId, filter.ProgrammeId.GetValueOrDefault());
            }
            else
            {
                document = _documentDataStore.OXODocGet(filter.DocumentId.Value, filter.ProgrammeId.GetValueOrDefault());
            }

            return await Task.FromResult(document);
        }
        public async Task<IEnumerable<SpecialFeature>> ListSpecialFeatures(ProgrammeFilter programmeFilter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpSpecialFeatureTypeGetMany());
        }
        public async Task<IEnumerable<TakeRateDataItem>> CalculateTakeRateAndVolumeByMarket(TakeRateFilter filter, DataChange forChange)
        {
            IEnumerable<TakeRateDataItem> retVal = Enumerable.Empty<TakeRateDataItem>();
            if (filter.Mode == Model.Enumerations.TakeRateResultMode.PercentageTakeRate)
            {
                retVal = await Task.FromResult(_takeRateDataStore.FdpTakeRateByMarketGetMany(filter, forChange.PercentageTakeRate));
            }
            else
            {
                retVal = await Task.FromResult(_takeRateDataStore.FdpVolumeByMarketGetMany(filter, forChange.Volume));
            }
            return retVal;
        }
        public async Task<FdpChangeset> GetUnsavedChangesForUser(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpLatestUnsavedChangesetByUserGetMany(filter));
        }
        public async Task<FdpChangesetHistory> GetChangesetHistory(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpTakeRateHistoryGet(filter));
        }
        public async Task<FdpChangeset> SaveChangeset(TakeRateFilter filter, FdpChangeset changesetToSave)
        {
            var savedChangeset = await Task.FromResult(_takeRateDataStore.FdpChangesetSave(filter, changesetToSave));
            var savedDataChanges = Enumerable.Empty<DataChange>();

            foreach (var dataChange in changesetToSave.Changes)
            {
                dataChange.FdpChangesetId = savedChangeset.FdpChangesetId;
            }
            savedDataChanges =
                await
                    Task.FromResult(
                        _takeRateDataStore.FdpChangesetDataItemsSave(filter, changesetToSave.Changes));
            
            savedChangeset.Changes = savedDataChanges.ToList();

            return savedChangeset;
        }
        public async Task<DataChange> RecalculateChangesetDataChange(DataChange changeToRecalculate) 
        {
            return await Task.FromResult(_takeRateDataStore.FdpChangesetDataItemRecalculate(changeToRecalculate));
        }
        public async Task<FdpChangeset> PersistChangeset(TakeRateFilter filter)
        {
            var changeset = await GetUnsavedChangesForUser(filter);
            changeset.Comment = filter.Comment;
            return await Task.FromResult(_takeRateDataStore.FdpChangesetPersist(filter, changeset));
        }

        public async Task<IEnumerable<ValidationResult>> PersistValidationErrors(TakeRateFilter filter, FluentValidation.Results.ValidationResult validationResult)
        {
            var results = new List<ValidationResult>();

            
            _takeRateDataStore.FdpValidationClear(filter);

            foreach (var validationError in validationResult.Errors)
            {
                try
                {

                    var state = (ValidationState) validationError.CustomState;
                    var validationData = new ValidationResult
                    {
                        TakeRateId = state.TakeRateId,

                        ValidationRule = state.ValidationRule,

                        FdpVolumeDataItemId = state.FdpVolumeDataItemId,
                        FdpTakeRateSummaryId = state.FdpTakeRateSummaryId,
                        FdpTakeRateFeatureMixId = state.FdpTakeRateFeatureMixId,
                        FdpChangesetDataItemId = state.FdpChangesetDataItemId,

                        MarketId = state.MarketId,
                        ModelId = state.ModelId,
                        FdpModelId = state.FdpModelId,
                        FeatureId = state.FeatureId,
                        FdpFeatureId = state.FdpFeatureId,
                        FeaturePackId = state.FeaturePackId,
                        ExclusiveFeatureGroup = state.ExclusiveFeatureGroup,

                        Message = validationError.ErrorMessage
                    };
                    validationData = await Task.FromResult(_takeRateDataStore.FdpValidationPersist(validationData));
                    results.Add(validationData);

                    foreach (var childState in state.ChildStates)
                    {
                        validationData = new ValidationResult
                        {
                            TakeRateId = childState.TakeRateId,

                            FdpVolumeDataItemId = childState.FdpVolumeDataItemId,
                            FdpTakeRateSummaryId = childState.FdpTakeRateSummaryId,
                            FdpTakeRateFeatureMixId = childState.FdpTakeRateFeatureMixId,
                            FdpChangesetDataItemId = childState.FdpChangesetDataItemId,

                            ValidationRule = state.ValidationRule,

                            MarketId = childState.MarketId,
                            ModelId = childState.ModelId,
                            FdpModelId = childState.FdpModelId,
                            FeatureId = childState.FdpFeatureId,
                            FdpFeatureId = childState.FdpFeatureId,
                            FeaturePackId = childState.FeaturePackId,

                            Message = validationError.ErrorMessage
                        };
                        validationData = await Task.FromResult(_takeRateDataStore.FdpValidationPersist(validationData));
                        results.Add(validationData);
                    }

                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            
            return results;
        }
        public async Task<FdpChangeset> UndoChangeset(TakeRateFilter takeRateFilter)
        {
            var changeset = await GetUnsavedChangesForUser(takeRateFilter);
            return await Task.FromResult(_takeRateDataStore.FdpChangesetUndo(takeRateFilter, changeset));
        }
        public async Task<FdpChangeset> RevertUnsavedChangesForUser(TakeRateFilter takeRateFilter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpChangesetRevert(takeRateFilter));
        }
        public async Task<int> GetVolumeForModel(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpVolumeByMarketAndModelGet(filter));
        }
        public async Task<int> GetVolumeForMarket(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpVolumeByMarketGet(filter));
        }
        public async Task<TakeRateDataItemNote> AddDataItemNote(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.TakeRateDataItemNoteSave(filter));
        }
        public async Task<FdpValidation> GetValidation(TakeRateFilter filter)
        {
            var validationResults = await Task.FromResult(_takeRateDataStore.FdpValidationGetMany(filter));
            var enumerable = validationResults as IList<ValidationResult> ?? validationResults.ToList();
            if (validationResults == null || !enumerable.Any())
            {
                return new EmptyFdpValidation();
            }
            return new FdpValidation()
            {
                ValidationResults = enumerable
            };
        }
        public async Task<Programme> GetProgramme(TakeRateFilter takeRateFilter)
        {
            return await Task.FromResult(_programmeDataStore.ProgrammeGet(takeRateFilter.ProgrammeId.GetValueOrDefault()));
        }
        public async Task<MarketReview> GetMarketReview(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpMarketReviewGet(filter));
        }
        public async Task<MarketReview> SetMarketReview(TakeRateFilter filter)
        {
            return await Task.FromResult(_takeRateDataStore.FdpMarketReviewSave(filter));
        }
        public async Task<PagedResults<MarketReview>> ListMarketReview(TakeRateFilter filter)
        {
            var marketReview = await Task.FromResult(_takeRateDataStore.FdpMarketReviewGetMany(filter));
            foreach (var currentMarketReview in marketReview.CurrentPage)
            {
                currentMarketReview.Programme = _programmeDataStore.ProgrammeGet(currentMarketReview.ProgrammeId);
                currentMarketReview.Document = _documentDataStore.OXODocGet(currentMarketReview.DocumentId,
                    currentMarketReview.ProgrammeId);
            }
            return marketReview;
        }
        public async Task<RawTakeRateData> GetRawData(TakeRateFilter filter)
        {
            var rawData = new RawTakeRateData()
            {
                DataItems = await Task.FromResult(_takeRateDataStore.FdpTakeRateDataGetRaw(filter)),
                SummaryItems = await Task.FromResult(_takeRateDataStore.FdpTakeRateSummaryGetRaw(filter)),
                FeatureMixItems = await Task.FromResult(_takeRateDataStore.FdpTakeRateFeatureMixGetRaw(filter)),
            };
            return rawData;
        }

        #endregion

        #region "Private Methods"

        private bool IsDocumentForVehicle(OXODoc documentToCheck, IVehicle vehicle)
        {
            return (!vehicle.ProgrammeId.HasValue || documentToCheck.ProgrammeId == vehicle.ProgrammeId.Value) &&
                (string.IsNullOrEmpty(vehicle.Gateway) || documentToCheck.Gateway == vehicle.Gateway);
        }
        private bool IsFilterValidForTakeRateData(TakeRateFilter filter)
        {
            //return filter.DocumentId.HasValue && (filter.MarketId.HasValue || filter.MarketGroupId.HasValue);
            return filter.DocumentId.HasValue;
        }

        #endregion

        #region "Private Members"

        private readonly OXODocDataStore _documentDataStore;
        private readonly TakeRateDataStore _takeRateDataStore;
        private readonly MarketGroupDataStore _marketGroupDataStore;
        private readonly ProgrammeDataStore _programmeDataStore;

        #endregion
    }
}
