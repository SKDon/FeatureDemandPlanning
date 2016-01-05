using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation;
using System;

namespace FeatureDemandPlanning.Model.Validators
{
    public class ImportExceptionParametersValidator : AbstractValidator<ImportExceptionParameters>
    {
        public const string ExceptionIdentifier = "EXCEPTION_ID";
        public const string ExceptionIdentifierWithAction = "EXCEPTION_ID_WITH_ACTION";
        public const string ImportQueueIdentifier = "IMPORT_QUEUE_ID";
        public const string ExceptionIdentifierWithActionProgrammeAndGateway = "EXCEPTION_ID_WITH_ACTION_AND_PROGRAMME";
        public const string NoValidation = "NO_VALIDATION";

        public ImportExceptionParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(ImportQueueIdentifier, () =>
            {
                RuleFor(p => p.ImportQueueId).NotNull().WithMessage("'ImportQueueId' not specified");
            });
            RuleSet(ExceptionIdentifier, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
            });
            RuleSet(ExceptionIdentifierWithAction, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => ImportAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(ExceptionIdentifierWithActionProgrammeAndGateway, () =>
            {
                RuleFor(p => p.ExceptionId).NotNull().WithMessage("'ExceptionId' not specified");
                RuleFor(p => p.Action).NotEqual(a => ImportAction.NotSet).WithMessage("'Action' not specified");
                RuleFor(p => p.ProgrammeId).NotNull().WithMessage("'ProgrammeId' not specified");
                RuleFor(p => p.Gateway).NotEmpty().WithMessage("'Gateway' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingDerivative), () =>
            {
                RuleFor(p => p.DerivativeCode).NotEmpty().WithMessage("'Derivative Code' not specified");
                RuleFor(p => p.BodyId).NotNull().WithMessage("'Body' not specified");
                RuleFor(p => p.EngineId).NotNull().WithMessage("'Engine' not specified");
                RuleFor(p => p.TransmissionId).NotNull().WithMessage("'Transmission' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingFeature), () =>
            {
                RuleFor(p => p.FeatureCode).NotEmpty().WithMessage("'Feature Code' not specified");
                RuleFor(p => p.FeatureDescription).NotNull().WithMessage("'Feature Description' not specified");
                RuleFor(p => p.FeatureGroupId).NotNull().WithMessage("'Feature Group' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddMissingTrim), () =>
            {
                RuleFor(p => p.TrimName).NotEmpty().WithMessage("'Name' not specified");
                RuleFor(p => p.TrimAbbreviation).NotEmpty().WithMessage("'Abbreviation' not specified");
                RuleFor(p => p.TrimLevel).NotEmpty().WithMessage("'Level' not specified");
                RuleFor(p => p.DPCK).NotEmpty().WithMessage("'DPCK' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.AddSpecialFeature), () =>
            {
                RuleFor(p => p.ImportFeatureCode).NotEmpty().WithMessage("'Import Feature Code' not specified");
                RuleFor(p => p.SpecialFeatureTypeId).NotEmpty().WithMessage("'Special Feature' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.IgnoreException), () =>
            {
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.MapMissingDerivative), () =>
            {
                RuleFor(p => p.ImportDerivativeCode).NotEmpty().WithMessage("'Import Derivative Code' not specified");
                RuleFor(p => p.DerivativeCode).NotEmpty().WithMessage("'Derivative Code' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.MapMissingFeature), () =>
            {
                RuleFor(p => p.ImportFeatureCode).NotEmpty().WithMessage("'Import Feature Code' not specified");
                RuleFor(p => p.FeatureCode).NotEmpty().WithMessage("'Feature Code' not specified");
            });
            RuleSet(Enum.GetName(typeof(ImportAction), ImportAction.MapMissingMarket), () =>
            {
                RuleFor(p => p.ImportMarket).NotEmpty().WithMessage("'Import Market' not specified");
                RuleFor(p => p.MarketId).NotNull().WithMessage("'Mapped Market Id' not specified");
            });
        }
        public static ImportExceptionParametersValidator ValidateImportExceptionParameters(ImportExceptionParameters parameters, string ruleSetName)
        {
            var validator = new ImportExceptionParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
            return validator;
        }
    }
}
