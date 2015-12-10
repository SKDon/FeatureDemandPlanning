using FeatureDemandPlanning.Model.Parameters;
using FluentValidation;
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

        public TakeRateParametersValidator()
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
                RuleFor(p => p.Changes).Must(NotBeAnEmptyChangeset).WithMessage("No changes to save");
            });
        }
        public static bool NotBeAnEmptyChangeset(IEnumerable<DataChange> changeSet)
        {
            return changeSet != null && changeSet.Any();
        }
        public static TakeRateParametersValidator ValidateTakeRateParameters(TakeRateParameters parameters, string ruleSetName)
        {
            var validator = new TakeRateParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
            return validator;
        }
    }
}
