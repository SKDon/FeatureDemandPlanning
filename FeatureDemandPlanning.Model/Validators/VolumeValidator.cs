using FeatureDemandPlanning.Model.Enumerations;
using FluentValidation;
using System.Linq;

namespace FeatureDemandPlanning.Model.Validators
{
    public class VolumeValidator : AbstractValidator<Volume>
    {
        public const string noImportData = "No import data exists for the selected vehicle(s).";
        public const string noOxoDocuments = "No OXO documents exist for the selected vehicle(s).";
        public const string noMappedImportData = "No import files have been selected";
        public const string noMappedOxoDocument = "No OXO document has been selected";

        public VolumeValidator(Volume volumeToValidate)
        {
            InstantiateValidators(volumeToValidate);
            SetupValidationRulesForVolume();
        }

        public static string GetRulesetsToValidate(VolumeValidationSection sectionToValidate)
        {
            var ruleSets = "*";

            switch (sectionToValidate)
            {
                case VolumeValidationSection.Vehicle:
                    ruleSets = "ForecastVehicle";
                    break;
                case VolumeValidationSection.Import:
                    ruleSets = "Import";
                    break;
                case VolumeValidationSection.Document:
                    ruleSets = "Document";
                    break;
                default:
                    ruleSets = "*";
                    break;
            }
            return ruleSets;
        }

        private void SetupValidationRulesForVolume()
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

        private bool HaveImportData(Volume volume)
        {
            return volume.Vehicle.AvailableImports.Any();
        }

        private bool HaveMappedImportData(Volume volume)
        {
            return volume.VolumeSummary.Any();
        }

        private bool HasMappedOxoDocument(Volume volume)
        {
            return volume.Document != null;
        }

        private bool HaveAnOxoDocument(Volume volume)
        {
            return volume.Vehicle.AvailableDocuments.Any();
        }

        private bool InstantiateValidators(Volume volume)
        {
            volumeToValidate = volume;
            vehicleValidator = new ForecastVehicleValidator();
            return true;
        }

        private Volume volumeToValidate = null;
        private ForecastVehicleValidator vehicleValidator = null;
    }
}
