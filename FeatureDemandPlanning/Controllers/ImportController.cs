using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Comparers;
using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportController : ControllerBase
    {
        public ImportController() : base()
        {
            ControllerType = ControllerType.SectionChild;
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
            //ValidateImportParameters(parameters, ImportParametersValidator.ImportQueueIdentifier);
            var filter = new ImportQueueFilter()
            {
                ImportQueueId = parameters.ImportQueueId,
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            var importView = await ImportViewModel.GetModel(DataContext, filter);

            return View(importView);
        }
        [HttpPost]
        public async Task<ActionResult> ListImportQueue(JQueryDataTableParameters param)
        {
            var js = new JavaScriptSerializer();
            var filter = new ImportQueueFilter();

            try
            {
                filter.InitialiseFromJson(param);

                var results = await ImportViewModel.GetModel(DataContext, filter);
                var jQueryResult = new JQueryDataTableResultModel(results.TotalRecords, results.TotalDisplayRecords);

                // Iterate through the results and put them in a format that can be used by jQuery datatables
                if (results.ImportQueue.CurrentPage.Any())
                {
                    foreach (var result in results.ImportQueue.CurrentPage)
                    {
                        var stringResult = new string[] 
                        { 
                            result.CreatedOn.ToString("g"), 
                            result.CreatedBy,
                            result.VehicleDescription,
                            Path.GetFileName(result.FilePath),
                            result.ImportStatus.Status,
                            result.ImportQueueId.ToString()
                        };

                        jQueryResult.aaData.Add(stringResult);
                    }
                }
                return Json(jQueryResult);
            }
            catch (ApplicationException ex)
            {
                return Json(ex);
            }
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        [OutputCache(Duration = 600, VaryByParam = "ImportParameter.Action")]
        public async Task<ActionResult> ModalContent(ImportParameters parameters)
        {
            //ValidateImportParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            var importView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(ImportExceptionParameters parameters)
        {
            //ValidateImportParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithActionAndProgramme);
            //ValidateImportParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HttpPost]
        public async Task<ActionResult> Upload(HttpPostedFileBase fileToUpload)
        {
            _fileToUpload = fileToUpload;

            try
            {
                _importView = await ImportViewModel.GetModel(DataContext);

                SaveImportFileToFileSystem();
                await QueueItemForProcessing();

                _importView.SetProcessState(new ProcessState(enums.ProcessStatus.Success,
                    String.Format("File '{0}' was uploaded successfully", _fileToUpload.FileName)));
            }
            catch (ApplicationException ex)
            {
                _importView.SetProcessState(ex);
            }

            return View(_importView);
        }
        [HttpGet]
        public async Task<ActionResult> Process(int importQueueId)
        {
            try
            {
                var filter = new ImportQueueFilter(importQueueId);

                _importView = await ImportViewModel.GetModel(DataContext, filter);
                await ProcessQueue(importQueueId);


                _importView = await ImportViewModel.GetModel(DataContext, filter);
                _importView.SetProcessState(
                    new ProcessState(enums.ProcessStatus.Success,
                                     "File was processed successfully"));
            }
            catch (ApplicationException ex)
            {
                _importView.SetProcessState(ex);
            }

            return RedirectToAction("Index");
        }
        

        #region "Private Methods"

        private string GetContentPartialViewName(ImportAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<ImportViewModel> GetModelFromParameters(ImportParameters parameters)
        {
            return await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(),
                parameters.Action);
        }

        //TODO Move all this to the model / business objects

        /// <summary>
        /// Saves the import file to file system.
        /// </summary>
        private void SaveImportFileToFileSystem()
        {
            var extension = Path.GetExtension(_fileToUpload.FileName);
            var uploadPath = DataContext.Configuration.Configuration.FdpUploadFilePath;

            _fileName = Path.Combine(uploadPath, String.Format("{0}{1}", Guid.NewGuid().ToString(), extension));

            _fileToUpload.SaveAs(_fileName);
        }

        /// <summary>
        /// Adds an entry to the import queue indicating that the uploaded file is to be processed
        /// </summary>
        private async Task<ImportQueue> QueueItemForProcessing()
        {
            var itemToQueue = new ImportQueue(UserName, _fileName);
            return await DataContext.Import.SaveImportQueue(itemToQueue);
        }

        /// <summary>
        /// Processes all items in the queue
        /// </summary>
        private async Task<ImportResult> ProcessQueue()
        {
            return await DataContext.Import.ProcessImportQueue();
        }

        /// <summary>
        /// Processes an individual item in the queue
        /// </summary>
        /// <param name="importQueueId">The import queue identifier</param>
        private async Task<ImportResult> ProcessQueue(int importQueueId)
        {
            var filter = new ImportQueueFilter(importQueueId);
            var itemToProcess = DataContext.Import.GetImportQueue(filter);
            
            return await DataContext.Import.ProcessImportQueue(itemToProcess.Result);
        }

        #endregion

        #region "Private members"

        private HttpPostedFileBase _fileToUpload = null;
        private string _fileName = String.Empty;
        private ImportViewModel _importView = null;
      
        #endregion
    }
}