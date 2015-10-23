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
            ControllerType = Controllers.ControllerType.SectionChild;
        }
        [HttpGet]
        public async Task<ActionResult> Index()
        {
            _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext);
            return View(_importView);
        }
        [HttpPost]
        public async Task<ActionResult> ListImportQueue(JQueryDataTableParameters param)
        {
            try
            {
                var js = new JavaScriptSerializer();

                var filter = new ImportQueueFilter();
                filter.InitialiseFromJson(param);

                var results = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
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
                        result.ImportStatus.Status,
                        string.Empty // action column
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
                _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext);

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

                _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
                await ProcessQueue(importQueueId);


                _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
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
        [HttpGet]
        public async Task<ActionResult> ImportExceptions(int importQueueId, 
                                                         ImportExceptionType exceptionType = ImportExceptionType.NotSet)
        {
            _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext,
                                    new ImportQueueFilter(importQueueId)
                                    {
                                        ExceptionType = exceptionType,
                                        PageIndex = 1,
                                        PageSize = 100
                                    });
            
            return View("ImportExceptions", _importView);
        }
        [HttpPost]
        public async Task<ActionResult> ListImportExceptions(ImportExceptionsParameterModel parameters)
        {
            try
            {
                var js = new JavaScriptSerializer();
                var filter = new ImportQueueFilter()
                {
                    ImportQueueId = parameters.ImportQueueId,
                    ExceptionType = parameters.ExceptionType,
                    FilterMessage = parameters.FilterMessage
                };
                filter.InitialiseFromJson(parameters);

                var results = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
                var jQueryResult = new JQueryDataTableResultModel(results);
                
                // Iterate through the results and put them in a format that can be used by jQuery datatables
                if (results.Exceptions.CurrentPage.Any())
                {
                    foreach (var result in results.Exceptions.CurrentPage)
                    {
                        var stringResult = new string[] 
                        { 
                            result.FdpImportErrorId.ToString(),
                            result.LineNumber.ToString(), 
                            result.ErrorTypeDescription,
                            result.ErrorMessage,
                            result.ErrorOn.ToString("dd/MM/yyyy HH:mm")
                        };

                        jQueryResult.aaData.Add(stringResult);
                    }

                    jQueryResult.TotalSuccess = results.Exceptions.TotalSuccess;
                    jQueryResult.TotalFail = results.Exceptions.TotalFail;
                }
                return Json(jQueryResult);
            }
            catch (Exception ex)
            {
                return Json(ex);
            }
        }
        [HttpPost]
        public async Task<ActionResult> ImportExceptionActionContextMenu(int exceptionId)
        {
            _importView = await ImportViewModel.GetFullAndPartialViewModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(exceptionId));
           
            return PartialView("_ImportExceptionAction", _importView);
        }
        [HttpPost]
        public async Task<ActionResult> ModalContent(int exceptionId, ImportExceptionAction actionId)
        {
            _importView = await ImportViewModel.GetFullAndPartialViewModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(exceptionId),
                actionId);

            return PartialView(GetContentView(actionId), _importView);
        }
        //[HttpPost]
        //public async Task<ActionResult> ImportExceptionIgnoreContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.IgnoreException);
            
        //    return PartialView("_IgnoreException", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> MapMarketContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId), 
        //        ImportExceptionAction.MapMissingMarket);
            
        //    return PartialView("_MapMarket", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> AddDerivativeContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.AddMissingDerivative);
            
        //    return PartialView("_AddDerivative", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> MapDerivativeContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.MapMissingDerivative);
            
        //    return PartialView("_MapDerivative", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> AddTrimContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.AddMissingTrim);
            
        //    return PartialView("_AddTrim", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> MapTrimContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.MapMissingTrim);

        //    return PartialView("_MapTrim", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> AddFeatureContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId), 
        //        ImportExceptionAction.AddMissingFeature);

        //    return PartialView("_AddFeature", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> AddSpecialFeatureContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId),
        //        ImportExceptionAction.AddSpecialFeature);
            
        //    return PartialView("_AddSpecialFeature", _importView);
        //}
        //[HttpPost]
        //public async Task<ActionResult> MapFeatureContent(int exceptionId)
        //{
        //    _importView = await ImportViewModel.GetFullAndPartialViewModel(
        //        DataContext,
        //        ImportQueueFilter.FromExceptionId(exceptionId), 
        //        ImportExceptionAction.MapMissingFeature);

        //    return PartialView("_MapFeature", _importView);
        //}
        [HttpPost]
        public async Task<ActionResult> ImportExceptionIgnoreAction(int exceptionId)
        {
            try
            {
                var filter = ImportQueueFilter.FromExceptionId(exceptionId);
                _importView = await ImportViewModel.GetFullAndPartialViewModel(DataContext, filter);
                _importView.CurrentException = await DataContext.Import.Ignore(filter);
            }
            catch (ApplicationException ex)
            {
                _importView.SetProcessState(ex);
            }

            return Json(_importView.CurrentException);
        }

        #region "Private Methods"

        private string GetContentView(ImportExceptionAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
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