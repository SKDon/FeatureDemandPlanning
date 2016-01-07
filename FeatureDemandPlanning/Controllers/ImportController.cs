using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;
using FluentValidation;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportController : ControllerBase
    {
        public ImportParameters Parameters { get; set; }
        public ImportQueue CurrentQueuedItem { get; set; }

        public ImportController() : base(ControllerType.SectionChild)
        {
            CurrentQueuedItem = new EmptyImportQueue();
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult ImportPage()
        {
            return RedirectToAction("ImportPage");
        }
        [HttpGet]
        public async Task<ActionResult> ImportPage(ImportParameters parameters)
        {
            Parameters = parameters;
            var importView = await GetModelFromParameters();

            return View(importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListImportQueue(ImportParameters parameters)
        {
            var filter = new ImportQueueFilter()
            {
                FilterMessage = parameters.FilterMessage,
                ImportStatus = (enums.ImportStatus)parameters.ImportStatusId.GetValueOrDefault(),
                Action = ImportAction.ImportQueue
            };
            filter.InitialiseFromJson(parameters);
            
            var results = await ImportViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results.TotalRecords, results.TotalDisplayRecords);

            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (results.ImportQueue.CurrentPage.Any())
            {
                foreach (var result in results.ImportQueue.CurrentPage)
                {
                    jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
                }
            }
            return Json(jQueryResult);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(ImportParameters parameters)
        {
            Parameters = parameters;
            var importView = await GetModelFromParameters();

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(ImportParameters parameters)
        {
            Parameters = parameters;
            ValidateImportParameters(Enum.GetName(Parameters.Action.GetType(), Parameters.Action));

            return RedirectToAction(Enum.GetName(Parameters.Action.GetType(), Parameters.Action), 
                                    ImportParameters.GetActionSpecificParameters(Parameters));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult Upload(HttpPostedFileBase fileToUpload,
                                    string carLine,
                                    string modelYear,
                                    string gateway,
                                    int? documentId)
        {
            Parameters = new ImportParameters
            {
                Action = ImportAction.Upload,
                UploadFile = fileToUpload,
                CarLine = carLine,
                ModelYear = modelYear,
                Gateway = gateway,
                DocumentId = documentId
            };
            ValidateImportParameters(ImportParametersValidator.Upload);

            SetProgrammeId();
            SetUploadFilePath();
            SaveImportFileToFileSystem();
            QueueItemForProcessing();
            ProcessQueuedItem();

            return JsonGetSuccess();
        }
     
        #region "Private Methods"

        private string GetContentPartialViewName(ImportAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<ImportViewModel> GetModelFromParameters()
        {
            return await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(),
                Parameters.Action);
        }
        private void SaveImportFileToFileSystem()
        {
            Parameters.UploadFile.SaveAs(Parameters.UploadFilePath);
        }
        private void SetProgrammeId()
        {
            var importView = GetModelFromParameters().Result;
            Parameters.ProgrammeId =
                importView.AvailableProgrammes
                    .First(p => p.VehicleName.Equals(Parameters.CarLine, StringComparison.InvariantCultureIgnoreCase) &&
                                p.ModelYear.Equals(Parameters.ModelYear, StringComparison.InvariantCultureIgnoreCase)).Id;
        }
        private void SetUploadFilePath()
        {
            var extension = Path.GetExtension(Parameters.UploadFile.FileName);
            Parameters.UploadFilePath = Path.Combine(DataContext.Configuration.Configuration.FdpUploadFilePath,
                                          string.Format("{0}{1}", Guid.NewGuid(), extension));
        }
        private void QueueItemForProcessing()
        {
            CurrentQueuedItem = DataContext.Import.SaveImportQueue(ImportQueue.FromParameters(Parameters));
        }
        private void ProcessQueuedItem()
        {
            var settings = new ImportFileSettings()
            {
                SkipFirstXRows = ConfigurationSettings.SkipFirstXRowsInImportFile
            };
            if (!(CurrentQueuedItem is EmptyImportQueue))
                DataContext.Import.ProcessImportQueue(CurrentQueuedItem, settings);
        }
        private void ValidateImportParameters(string ruleSetName)
        {
            var validator = new ImportParametersValidator(DataContext);
            var result = validator.Validate(Parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }

        #endregion
    }

    #region "Validation Classes"

    internal class ImportParametersValidator : AbstractValidator<ImportParameters>
    {
        public const string Upload = "UPLOAD";
        public const string NoValidation = "NO_VALIDATION";

        public IDataContext DataContext { get; set; }
        public IEnumerable<Programme> AvailableProgrammes { get; set; }

        public ImportParametersValidator(IDataContext context)
        {
            DataContext = context;
            AvailableProgrammes = DataContext.Vehicle.ListProgrammes(new ProgrammeFilter());

            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(Upload, () =>
            {
                RuleFor(p => p.UploadFile)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(NotBeEmpty)
                    .WithMessage("'File to import' not specified")
                    .Must(BeAnExcelFile)
                    .WithMessage("'File to import' is not a valid Excel file");
                RuleFor(p => p.CarLine).NotEmpty().WithMessage("'Car Line' not specified");
                RuleFor(p => p.ModelYear).NotEmpty().WithMessage("'Model Year' not specified");
                RuleFor(p => p.Gateway).NotEmpty().WithMessage("'Gateway' not specified");
                RuleFor(p => p.DocumentId).NotNull().WithMessage("'OXO Document' not specified");
                    
                RuleFor(p => p)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .Must(BeAValidCarLine)
                    .WithMessage("Selected car line not found or you do not have permissions to upload data to it")
                    .Must(BeAValidModelYear)
                    .WithMessage("Model year not valid for the selected car line or you do not have permissions to upload data to it")
                    .Must(BeAValidGateway)
                    .WithMessage("Gateway not valid for the selected car line / model year or you do not have permissions to upload data to it");

            });
        }

        private bool BeAValidGateway(ImportParameters parameters)
        {
            return AvailableProgrammes.Where(p => p.VehicleName.Equals(parameters.CarLine, StringComparison.InvariantCultureIgnoreCase) &&
                                                  p.ModelYear.Equals(parameters.ModelYear, StringComparison.InvariantCultureIgnoreCase) &&
                                                  p.Gateway.Equals(parameters.Gateway, StringComparison.InvariantCultureIgnoreCase)).Any();
        }
        private bool BeAValidModelYear(ImportParameters parameters)
        {
            return AvailableProgrammes.Where(p => p.VehicleName.Equals(parameters.CarLine, StringComparison.InvariantCultureIgnoreCase) &&
                                                  p.ModelYear.Equals(parameters.ModelYear, StringComparison.InvariantCultureIgnoreCase)).Any();
        }
        private bool BeAValidCarLine(ImportParameters parameters)
        {
            return AvailableProgrammes.Where(p => p.VehicleName.Equals(parameters.CarLine, StringComparison.InvariantCultureIgnoreCase)).Any();
        }
        private bool BeAnExcelFile(HttpPostedFileBase arg)
        {
            return arg.FileName.EndsWith(".xls") || arg.FileName.EndsWith(".xlsx");
        }
        private bool NotBeEmpty(HttpPostedFileBase arg)
        {
            return arg != null && arg.ContentLength > 0;
        }
    }

    #endregion
}