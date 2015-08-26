using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Comparers;
using enums = FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Models;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportController : ControllerBase
    {
        public ImportController()
        {
            PageIndex = 1;
            PageSize = DataContext.ConfigurationSettings.DefaultPageSize;
            ControllerType = Controllers.ControllerType.SectionChild;
        }

        /// <summary>
        /// Lists the files to import
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public ActionResult Index()
        {
            return View(new ImportViewModel(DataContext));
        }

        [HttpGet]
        public async Task<ActionResult> ListImportQueue(JQueryDataTableParamModel param)
        {
            var js = new JavaScriptSerializer();

            var filter = new ImportQueueFilter();
            if (!string.IsNullOrEmpty(param.sSearch))
            {
                filter = (ImportQueueFilter)js.Deserialize(param.sSearch, typeof(ImportQueueFilter));
            }
            filter.InitialiseFromJson(param);
            
            var results = await GetFullAndPartialViewModel(filter);
            var jQueryResult = JQueryDataTableResultModel.GetResultsFromParameters(param, results.TotalRecords);
            
            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (results.ImportQueue.CurrentPage.Any())
            {
                foreach (var result in results.ImportQueue.CurrentPage)
                {
                    var stringResult = new string[] 
                    { 
                        result.CreatedOn.ToString("g"), 
                        result.CreatedBy,
                        result.FilePath,
                        result.ImportStatus.Status,
                        string.Empty // action column
                    };

                    jQueryResult.aaData.Add(stringResult);
                }
            }

            return Json(jQueryResult, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Uploads the specified file for import
        /// </summary>
        /// <param name="fileToUpload">The file to upload.</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<ActionResult> Upload(HttpPostedFileBase fileToUpload)
        {
            _fileToUpload = fileToUpload;

            try
            {
                var filter = new ImportQueueFilter();
                _importView = await GetFullAndPartialViewModel(filter);

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

        /// <summary>
        /// Processes the specified file in the import queue
        /// </summary>
        /// <param name="importQueueId">The import queue identifier</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ActionResult> Process(int importQueueId)
        {
            try
            {
                var filter = new ImportQueueFilter(importQueueId);

                _importView = await GetFullAndPartialViewModel(filter);
                await ProcessQueue(importQueueId);

                
                _importView = await GetFullAndPartialViewModel(filter);
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

        /// <summary>
        /// Gets the full and partial view model to be used by the controller actions
        /// </summary>
        /// <returns></returns>
        private async Task<ImportViewModel> GetFullAndPartialViewModel(ImportQueueFilter filter)
        {
            var model = new ImportViewModel(DataContext)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                ImportQueue = await DataContext.Import.ListImportQueue(filter)
            };

            // If there are any items queued, get the total pages and record count from the queued items
            if (model.ImportQueue.TotalRecords > 0)
            {
                model.TotalPages = model.ImportQueue.TotalPages;
                model.TotalRecords = model.ImportQueue.TotalRecords;
            }
            return model;
        }

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
        private async Task<bool> ProcessQueue()
        {
            return await DataContext.Import.ProcessImportQueue();
        }

        /// <summary>
        /// Processes an individual item in the queue
        /// </summary>
        /// <param name="importQueueId">The import queue identifier</param>
        private async Task<bool> ProcessQueue(int importQueueId)
        {
            var filter = new ImportQueueFilter(importQueueId);
            var itemToProcess = DataContext.Import.GetImportQueue(filter);
            
            return await DataContext.Import.ProcessImportQueue(itemToProcess.Result);
        }

        #endregion

        #region "Private members"

        private HttpPostedFileBase _fileToUpload = null;
        private string _fileName = String.Empty;
        private string _error = String.Empty;
        private ImportViewModel _importView = null;
      
        #endregion
    }
}