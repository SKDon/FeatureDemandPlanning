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
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportController : ControllerBase
    {
        public ImportController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        public async Task<ActionResult> Index()
        {
            _importView = await ImportViewModel.GetModel(DataContext);
            return View(_importView);
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
                            result.FilePath,
                            result.ImportStatus.Status
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