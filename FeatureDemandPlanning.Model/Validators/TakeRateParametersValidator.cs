using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation;
using System.Linq;

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
