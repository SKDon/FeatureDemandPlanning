using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation;
using FluentValidation.Validators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateParametersValidator : AbstractValidator<TakeRateParameters>
    {
        public const string TakeRateIdentifier = "TAKE_RATE_ID";
        public const string TakeRateIdentifierWithChangeset = "TAKE_RATE_ID_WITH_CHANGESET";
        public const string NoValidation = "NO_VALIDATION";

        public TakeRateParametersValidator(IDataContext context)
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
                RuleFor(p => p.Changeset.Changes).SetValidator(new AllFeatureVolumesMustBeLessThanModelVolume(context));
                RuleFor(p => p.Changeset.Changes).SetValidator(new AllModelVolumesMustBeLessThanMarketVolume(context));
                RuleFor(p => p.Changeset).SetValidator(new ChangesetValidator(context));
            });
        }
        
        public static TakeRateParametersValidator ValidateTakeRateParameters(IDataContext context, 
                                                                             TakeRateParameters parameters, 
                                                                             string ruleSetName)
        {
            var validator = new TakeRateParametersValidator(context);
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
            return validator;
        }
    }
    public class AllFeatureVolumesMustBeLessThanModelVolume : PropertyValidator
    {
        public AllFeatureVolumesMustBeLessThanModelVolume(IDataContext context)
            : base("Feature volume cannot be greater than the volume for the model")
        {
            _context = context;
        }

        protected TakeRateParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as TakeRateParameters;
            var changes = context.PropertyValue as IEnumerable<DataChange>;

            if (changes != null)
            {
                return !changes.Any(c => IsFeatureVolumeGreaterThanVolumeForModel(c));
            }

            return true;
        }

        private bool IsFeatureVolumeGreaterThanVolumeForModel(DataChange change)
        {
            if (!change.IsFeatureChange)
                return false;

            var filter = TakeRateFilter.FromTakeRateParameters(Parameters);
            var modelVolume = _context.TakeRate.GetVolumeForModel(filter).Result;

            return change.Volume > modelVolume;
        }

        private IDataContext _context;
    }
    public class AllModelVolumesMustBeLessThanMarketVolume : PropertyValidator
    {
        public AllModelVolumesMustBeLessThanMarketVolume(IDataContext context)
            : base("Feature volume cannot be greater than the volume for the model")
        {
            _context = context;
        }

        protected TakeRateParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as TakeRateParameters;
            var changes = context.PropertyValue as IEnumerable<DataChange>;

            if (changes != null)
            {
                return !changes.Any(c => IsVolumeGreaterThanVolumeForMarket(c));
            }

            return true;
        }

        private bool IsVolumeGreaterThanVolumeForMarket(DataChange change)
        {
            if (!change.IsModelSummary)
                return false;

            var filter = TakeRateFilter.FromTakeRateParameters(Parameters);
            var marketVolume = _context.TakeRate.GetVolumeForMarket(filter).Result;

            return change.Volume > marketVolume;
        }

        private IDataContext _context;
    }
    /// <summary>
    /// Validator for a whole changeset
    /// </summary>
    public class ChangesetValidator : AbstractValidator<FdpChangeset>
    {
        public ChangesetValidator(IDataContext context)
        {
            RuleFor(c => c).Must(NotBeAnEmptyChangeset).WithMessage("No changes to save");
            RuleFor(c => c.Changes).SetCollectionValidator(new DataChangeValidator(context));
        }
        public static bool NotBeAnEmptyChangeset(FdpChangeset changeSet)
        {
            return changeSet != null && changeSet.Changes.Any();
        }
    }
    /// <summary>
    /// Validator for a data change within a changeset
    /// </summary>
    public class DataChangeValidator : AbstractValidator<DataChange>
    {
        public DataChangeValidator(IDataContext context)
        {
            _context = context;

            RuleFor(d => d).Must(BeLessThan100Percent).WithMessage("% Take cannot be more than 100%");
            RuleFor(d => d).Must(BeGreaterThanOrEqualTo0Percent).WithMessage("% Take cannot be less than 0%");
        }
        public static bool BeLessThan100Percent(DataChange change)
        {
            return change.PercentageTakeRate.GetValueOrDefault() < 1;
        }
        public static bool BeGreaterThanOrEqualTo0Percent(DataChange change)
        {
            return change.PercentageTakeRate.GetValueOrDefault() >= 0;
        }

        private IDataContext _context = null;
    }
}
