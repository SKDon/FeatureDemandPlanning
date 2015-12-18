using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
                case TakeRateDocumentValidationSection.Document:
                    ruleSets = "Document";
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
            RuleSet("Document", () =>
            {
                // We must have an OXO document for the selected vehicle
                RuleFor(v => v)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(HaveAnOxoDocument)
                    .WithMessage(noOxoDocuments)
                    .Must(HasMappedOxoDocument)
                    .WithMessage(noMappedOxoDocument);
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
