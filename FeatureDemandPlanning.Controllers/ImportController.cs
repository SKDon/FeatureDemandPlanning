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
using FeatureDemandPlanning.Model.Results;
using FeatureDemandPlanning.Model.Validators;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportController : ControllerBase
    {
        public ImportParameters Parameters { get; set; }
        public ImportQueue CurrentQueuedItem { get; set; }
        public ImportResult Result { get; set; }

        public ImportController(IDataContext context) : base(context, ControllerType.SectionChild)
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
        public async Task<ActionResult> ContextMenu(ImportParameters parameters)
        {
            ImportParametersValidator.ValidateImportParameters(parameters, ImportParametersValidator.ImportQueueIdentifier, DataContext);

            var importView = await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(parameters.ImportQueueId.Value)
                {
                    Action = ImportAction.ImportQueueItem
                });

            return PartialView("_ContextMenu", importView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(ImportParameters parameters)
        {
            if (parameters.Action != ImportAction.Upload)
            {
                ImportParametersValidator
                    .ValidateImportParameters(parameters, ImportParametersValidator.ImportQueueIdentifier, DataContext);
            }

            var importView = GetModelFromParameters(parameters).Result;

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
            ValidateProcessedItem();
            RefreshQueuedItem();

            var retVal = JsonGetSuccess();
            if (CurrentQueuedItem.HasErrors)
            {
                
                retVal = JsonGetFailure(string.Format("Import Completed with {0} {1} error(s)", 
                    CurrentQueuedItem.ErrorCount, 
                    ImportQueue.GetErrorTypeAbbreviation(CurrentQueuedItem.ErrorType)));
            }

            return retVal;
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> DeleteImport(ImportParameters parameters)
        {
            var filter = new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault());
            var importView = await GetModelFromParameters(parameters);

            filter.ImportStatus = enums.ImportStatus.Cancelled;
            importView.CurrentImport = await DataContext.Import.UpdateStatus(filter);
            
            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
     
        #region "Private Methods"

        private static string GetContentPartialViewName(ImportAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<ImportViewModel> GetModelFromParameters()
        {
            return ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(),
                Parameters.Action).Result;
        }
        private async Task<ImportViewModel> GetModelFromParameters(ImportParameters parameters)
        {
            if (parameters.Action == ImportAction.DeleteImport)
            {
                return await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault()) { Action = parameters.Action },
                parameters.Action);
            }
            if (parameters.Action == ImportAction.Upload)
            {
                return await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter() { Action = parameters.Action },
                parameters.Action);
            }
            return GetModelFromParameters().Result;
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
            var uploadPath = Path.Combine(ConfigurationSettings.GetString("FdpUploadFilePath"),
                                          string.Format("{0}{1}", Guid.NewGuid(), extension));

            Log.Debug(ConfigurationSettings.GetString("FdpUploadFilePath"));
            Log.Debug(string.Format("Upload Path: {0}", uploadPath));
            Parameters.UploadFilePath = uploadPath;
        }
        private void QueueItemForProcessing()
        {
            CurrentQueuedItem = DataContext.Import.SaveImportQueue(ImportQueue.FromParameters(Parameters));
        }
        private void ProcessQueuedItem()
        {
            Exception errorState = null;

            try
            {
                var settings = new ImportFileSettings()
                {
                    SkipFirstXRows = ConfigurationSettings.GetInteger("SkipFirstXRowsInImportFile")
                };
                if (!(CurrentQueuedItem is EmptyImportQueue))
                {
                    Result = DataContext.Import.ProcessImportQueue(CurrentQueuedItem, settings);
                }
            }
            catch (Exception ex)
            {
                errorState = ex;
            }
            finally
            {
                if (errorState != null)
                {
                    DataContext.Import.UpdateStatus(new ImportQueueFilter()
                    {
                        ImportQueueId = CurrentQueuedItem.ImportQueueId,
                        ImportStatus = enums.ImportStatus.Error,
                        ErrorMessage = errorState.Message
                    });
                }
            }
        }

        private void ValidateProcessedItem()
        {
            if (Result == null || !Result.TakeRateId.HasValue)
                return;

            var filter = new TakeRateFilter()
            {
                TakeRateId = Result.TakeRateId
            };

            var markets = DataContext.Market.ListMarkets(filter).Result;
            foreach (var market in markets)
            {
                try
                {
                    filter.MarketId = market.Id;
                    var rawData = DataContext.TakeRate.GetRawData(filter).Result;

                    var validationResults = Validator.Validate(rawData);
                    Validator.Persist(DataContext, filter, validationResults).RunSynchronously();
                }
                catch (ValidationException vex)
                {
                    // Sink the exception, as we don't want any validation errors propagating up
                }
            }
        }
        private void RefreshQueuedItem()
        {
            if (CurrentQueuedItem == null || CurrentQueuedItem is EmptyImportQueue)
                return;

            CurrentQueuedItem = 
                DataContext.Import.GetImportQueue(new ImportQueueFilter(CurrentQueuedItem.ImportQueueId.GetValueOrDefault())).Result;
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
        public const string ImportQueueIdentifier = "IMPORT_QUEUE_IDENTIFIER";

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
                    .Must(BeAnExcelOrCsvFile)
                    .WithMessage("'File to import' is not a valid Excel or CSV file");
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
            RuleSet(ImportQueueIdentifier, () =>
            {
                RuleFor(p => p.ImportQueueId)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .WithMessage("'Import Queue Id' not specified");
            });
        }
        public static ImportParametersValidator ValidateImportParameters(ImportParameters parameters, string ruleSetName, IDataContext context)
        {
            var validator = new ImportParametersValidator(context);
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
            return validator;
        }

        private bool BeAValidGateway(ImportParameters parameters)
        {
            return AvailableProgrammes.Any(p => p.VehicleName.Equals(parameters.CarLine, StringComparison.InvariantCultureIgnoreCase) &&
                                                  p.ModelYear.Equals(parameters.ModelYear, StringComparison.InvariantCultureIgnoreCase) &&
                                                  p.Gateway.Equals(parameters.Gateway, StringComparison.InvariantCultureIgnoreCase));
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
        private bool BeAnExcelOrCsvFile(HttpPostedFileBase arg)
        {
            return BeAnExcelFile(arg) || arg.FileName.EndsWith(".csv");
        }
        private bool NotBeEmpty(HttpPostedFileBase arg)
        {
            return arg != null && arg.ContentLength > 0;
        }
    }

    #endregion
}