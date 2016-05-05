using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation.Results;

namespace FeatureDemandPlanning.Model.Validators
{
    public static class Validator
    {
        public static FluentValidation.Results.ValidationResult Validate(RawTakeRateData data)
        {
            var watch = Stopwatch.StartNew();
            FluentValidation.Results.ValidationResult featureLevelResults = null;
            FluentValidation.Results.ValidationResult modelLevelResults = null;
            FluentValidation.Results.ValidationResult featureMixResults = null;

            Parallel.Invoke(
                () => featureLevelResults = TakeRateDataValidator.ValidateData(data),  
                () => modelLevelResults = TakeRateSummaryValidator.ValidateData(data),
                () => featureMixResults = TakeRateFeatureMixValidator.ValidateData(data)
            );

            var allErrors = featureLevelResults.Errors
                .Concat(modelLevelResults.Errors)
                .Concat(featureMixResults.Errors);

            var validationFailures = allErrors as IList<ValidationFailure> ?? allErrors.ToList();

            watch.Stop();
            Console.WriteLine("Total Validation Time : {0} ms", watch.ElapsedMilliseconds);
            
            return new FluentValidation.Results.ValidationResult(validationFailures);
        }

        public static async Task<IEnumerable<ValidationResult>> Persist(IDataContext context,
            TakeRateFilter filter,
            FluentValidation.Results.ValidationResult results)
        {
            return await context.TakeRate.PersistValidationErrors(filter, results);
        }
    }
    // Stores state information for validation such that it can be stored in the database and the appropriate objects
    // can be referenced
    public class ValidationState
    {
        public ValidationRule ValidationRule { get; set; }
        public int TakeRateId { get; set; }
        public int MarketId { get; set; }
        public int? ModelId { get; set; }
        public int? FdpMarketId { get; set; }
        public int? FeatureId { get; set; }
        public int? FdpFeatureId { get; set; }
        public int? FdpModelId { get; set; }
        public int? FeaturePackId { get; set; }
        public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }
        public string ExclusiveFeatureGroup { get; set; }
        public string PackName { get; set; }

        public int? FdpVolumeDataItemId { get; set; }
        public int? FdpTakeRateSummaryId { get; set; }
        public int? FdpTakeRateFeatureMixId { get; set; }
        public int? FdpChangesetDataItemId { get; set; }

        public IEnumerable<ValidationState> ChildStates { get; set; }

        public ValidationState(ValidationRule rule)
        {
            ValidationRule = rule;
            ChildStates = Enumerable.Empty<ValidationState>();
        }
        public ValidationState(ValidationRule rule, RawTakeRateDataItem dataItem) : this(rule)
        {
            TakeRateId = dataItem.FdpVolumeHeaderId;
            MarketId = dataItem.MarketId;
            ModelId = dataItem.ModelId;
            FdpModelId = dataItem.FdpModelId;
            FeatureId = dataItem.FeatureId;
            FdpFeatureId = dataItem.FdpFeatureId;
            FeaturePackId = dataItem.FeaturePackId;
            Volume = dataItem.Volume;
            PercentageTakeRate = dataItem.PercentageTakeRate;
            ExclusiveFeatureGroup = dataItem.ExclusiveFeatureGroup;

            FdpVolumeDataItemId = dataItem.FdpVolumeDataItemId;
            FdpChangesetDataItemId = dataItem.FdpChangesetDataItemId;
        }
        public ValidationState(ValidationRule rule, RawTakeRateSummaryItem summaryItem)
            : this(rule)
        {
            TakeRateId = summaryItem.FdpVolumeHeaderId;
            MarketId = summaryItem.MarketId;
            ModelId = summaryItem.ModelId;
            FdpModelId = summaryItem.FdpModelId;
            Volume = summaryItem.Volume;
            PercentageTakeRate = summaryItem.PercentageTakeRate;

            FdpTakeRateSummaryId = summaryItem.FdpTakeRateSummaryId;
            FdpChangesetDataItemId = summaryItem.FdpChangesetDataItemId;
        }
        public ValidationState(ValidationRule rule, RawTakeRateFeatureMixItem mixItem)
            : this(rule)
        {
            TakeRateId = mixItem.FdpVolumeHeaderId;
            MarketId = mixItem.MarketId;
            FeatureId = mixItem.FeatureId;
            FdpFeatureId = mixItem.FdpFeatureId;
            FeaturePackId = mixItem.FeaturePackId;
            Volume = mixItem.Volume;
            PercentageTakeRate = mixItem.PercentageTakeRate;

            FdpTakeRateFeatureMixId = mixItem.FdpTakeRateFeatureMixId;
            FdpChangesetDataItemId = mixItem.FdpChangesetDataItemId;
        }
        public ValidationState(ValidationRule rule, EfgGrouping group) : this(rule)
        {
            TakeRateId = group.TakeRateId;
            MarketId = group.MarketId;
            ModelId = group.ModelId;
            FeatureId = group.FeatureId;
            ExclusiveFeatureGroup = group.ExclusiveFeatureGroup;
        }
        public ValidationState(ValidationRule rule, FeaturePack pack) : this(rule)
        {
            TakeRateId = pack.TakeRateId;
            MarketId = pack.MarketId;
            ModelId = pack.ModelId;
            FeaturePackId = pack.FeaturePackId;
            PackName = pack.PackName;
        }
        public ValidationState(ValidationRule rule, IEnumerable<RawTakeRateDataItem> dataItems) : this(rule)
        {
            ChildStates = dataItems.Select(dataItem => new ValidationState(ValidationRule.VolumeForFeatureGreaterThanModel, dataItem));
        }
    }
}
