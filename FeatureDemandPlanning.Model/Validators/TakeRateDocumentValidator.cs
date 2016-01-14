using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;
using System.Linq;

namespace FeatureDemandPlanning.Model.Validators
{
    public class TakeRateDocumentValidator : AbstractValidator<TakeRateDocument>
    {
        public const string noImportData = "No import data exists for the selected vehicle(s).";
        public const string noOxoDocuments = "No OXO documents exist for the selected vehicle(s).";
        public const string noMappedImportData = "No import files have been selected";
        public const string noMappedOxoDocument = "No OXO document has been selected";

        public TakeRateDocumentValidator(TakeRateDocument takeRateDocumentToValidate)
        {
            InstantiateValidators(takeRateDocumentToValidate);
            SetupValidationRulesFortakeRateDocument();
        }

        public static string GetRulesetsToValidate(TakeRateDocumentValidationSection sectionToValidate)
        {
            var ruleSets = "*";

            switch (sectionToValidate)
            {
                case TakeRateDocumentValidationSection.Vehicle:
                    ruleSets = "ForecastVehicle";
                    break;
                case TakeRateDocumentValidationSection.Import:
                    ruleSets = "Import";
                    break;
                case TakeRateDocumentValidationSection.TakeRateFile:
                    ruleSets = "TakeRateFile";
                    break;
                default:
                    ruleSets = "*";
                    break;
            }
            return ruleSets;
        }

        private void SetupValidationRulesFortakeRateDocument()
        {
            RuleSet("ForecastVehicle", () =>
            {
                RuleFor(v => v.Vehicle)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .SetValidator(vehicleValidator);

                RuleFor(v => v)
                    .NotNull()
                    .Must(HaveImportData)
                    .WithMessage(noImportData)
                    .Must(HaveAnOxoDocument)
                    .WithMessage(noOxoDocuments);
            });

            RuleSet("Import", () =>
            {
                RuleFor(v => v)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(HaveImportData)
                    .WithMessage(noImportData)
                    .Must(HaveMappedImportData)
                    .WithMessage(noMappedImportData);
            });
            RuleSet("TakeRateFile", () =>
            {
                RuleFor(v => v.TakeRateData).NotNull();
                RuleFor(v => v.TakeRateData).AllFeatureVolumesMustBeLessThanModelVolume();
            });
        }



        private bool HaveImportData(TakeRateDocument takeRateDocument)
        {
            return takeRateDocument.Vehicle.AvailableImports.Any();
        }

        private bool HaveMappedImportData(TakeRateDocument takeRateDocument)
        {
            return takeRateDocument.TakeRateSummary.Any();
        }

        private bool HasMappedOxoDocument(TakeRateDocument takeRateDocument)
        {
            return takeRateDocument.UnderlyingOxoDocument != null;
        }

        private bool HaveAnOxoDocument(TakeRateDocument takeRateDocument)
        {
            return takeRateDocument.Vehicle.AvailableDocuments.Any();
        }

        private bool InstantiateValidators(TakeRateDocument takeRateDocument)
        {
            takeRateDocumentToValidate = takeRateDocument;
            vehicleValidator = new ForecastVehicleValidator();
            return true;
        }

        private TakeRateDocument takeRateDocumentToValidate = null;
        private ForecastVehicleValidator vehicleValidator = null;
    }
}
