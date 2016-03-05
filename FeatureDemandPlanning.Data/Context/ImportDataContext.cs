using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class ImportDataContext : BaseDataContext, IImportDataContext
    {
        public ImportDataContext(string cdsId) : base(cdsId)
        {
            _importDataStore = new ImportQueueDataStore(cdsId);
            _marketDataStore = new MarketDataStore(cdsId);
            _derivativeDataStore = new DerivativeDataStore(cdsId);
            _featureDataStore = new FeatureDataStore(cdsId);
            _trimDataStore = new ModelTrimDataStore(cdsId);
        }
        public async Task<ImportQueue> GetImportQueue(ImportQueueFilter filter)
        {
            if (!filter.ImportQueueId.HasValue)
                throw new ArgumentNullException("ImportQueueId not specified");
            
            return await Task.FromResult(_importDataStore.ImportQueueGet(filter.ImportQueueId.Value));
        }
        public async Task<ImportSummary> GetImportSummary(ImportQueueFilter filter)
        {
            return await Task.FromResult(_importDataStore.ImportQueueSummaryGet(filter.ImportQueueId.Value));
        }
        public async Task<PagedResults<ImportQueue>> ListImportQueue(ImportQueueFilter filter)
        {
            var results = await Task.FromResult(
                _importDataStore.ImportQueueGetMany(filter));
                
            return results;
        }
        public async Task<ImportError> SaveException(ImportQueueFilter filter)
        {
            return await Task.FromResult(_importDataStore.ImportExceptionSave(filter));
        }
        public ImportQueue SaveImportQueue(ImportQueue importItem)
        {
            return _importDataStore.ImportQueueSave(importItem);
        }
        public async Task<ImportQueue> GetProcessStatus(ImportQueue importItem)
        {
            var importQueueId = importItem.ImportQueueId.GetValueOrDefault();
            
            return await Task.FromResult(_importDataStore.ImportQueueGet(importQueueId));
        }
        public async Task<ImportQueue> UpdateStatus(ImportQueueFilter filter)
        {
            return await Task.FromResult(_importDataStore.ImportQueueUpdateStatus(filter));
        }
        Task<ImportStatus> IImportDataContext.GetProcessStatus(ImportQueue importItem)
        {
            throw new NotImplementedException();
        }
        public async Task<ImportError> IgnoreException(ImportQueueFilter filter)
        {
            return await Task.FromResult(_importDataStore.ImportExceptionIgnore(filter));
        }
        public async Task<ImportError> MapMarket(ImportQueueFilter filter, FdpMarketMapping mapping)
        {
            var task = await Task.FromResult(_marketDataStore.FdpMarketMappingSave(mapping));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> AddDerivative(ImportQueueFilter filter, FdpDerivative derivativeToAdd)
        {
            var task = await Task.FromResult(_derivativeDataStore.FdpDerivativeSave(derivativeToAdd));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> MapDerivative(ImportQueueFilter filter, FdpDerivativeMapping derivativeMapping)
        {
            var task = await Task.FromResult(_derivativeDataStore.FdpDerivativeMappingSave(derivativeMapping));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> AddFeature(ImportQueueFilter filter, FdpFeature featureToAdd)
        {
            var task = await Task.FromResult(_featureDataStore.FdpFeatureSave(featureToAdd));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> AddSpecialFeature(ImportQueueFilter filter, FdpSpecialFeature specialFeature)
        {
            var task = await Task.FromResult(_featureDataStore.FdpSpecialFeatureSave(specialFeature));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> MapFeature(ImportQueueFilter filter, FdpFeatureMapping featureMapping)
        {
            var task = await Task.FromResult(_featureDataStore.FeatureMappingSave(featureMapping));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> AddTrim(ImportQueueFilter filter, FdpTrim trimToAdd)
        {
            var task = await Task.FromResult(_trimDataStore.FdpTrimSave(trimToAdd));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<ImportError> MapTrim(ImportQueueFilter filter, FdpTrimMapping trimMapping)
        {
            var task = await Task.FromResult(_trimDataStore.TrimMappingSave(trimMapping));
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public ImportResult ProcessImportQueue(ImportQueue queuedItem, ImportFileSettings fileSettings)
        {
            var result = new ImportResult();

            queuedItem.ImportData = GetImportFileAsDataTable(queuedItem, fileSettings);
            queuedItem = BulkImportDataTableToDataStore(queuedItem);
            queuedItem = ProcessImportData(queuedItem);

            File.Delete(queuedItem.FilePath);

            result.Status = queuedItem.ImportStatus;
            result.TakeRateId = queuedItem.TakeRateId;

            return result;
        }
        public ImportResult ReprocessImportQueue(ImportQueue queuedItem)
        {
            var result = new ImportResult();
            queuedItem = ProcessImportData(queuedItem);
            result.Status = queuedItem.ImportStatus;
            
            return result;
        }
        public async Task<ImportError> GetException(ImportQueueFilter filter)
        {
            return await Task.FromResult(_importDataStore.ImportErrorGet(filter));
        }
        public async Task<PagedResults<ImportError>> ListExceptions(ImportQueueFilter filter)
        {
            return await Task.FromResult(
                _importDataStore.ImportErrorGetMany(filter));

        }
        public async Task<IEnumerable<ImportExceptionType>> ListExceptionTypes(ImportQueueFilter filter)
        {
            return await Task.FromResult(
                _importDataStore.ImportExceptionTypeGetMany(filter));
        }
        public async Task<IEnumerable<ImportStatus>> ListImportStatuses()
        {
            return await Task.FromResult(
                _importDataStore.ImportStatusGetMany());
        }
        public async Task<FdpImportErrorExclusion> GetFdpImportErrorExclusion(IgnoredExceptionFilter filter)
        {
            return await Task.FromResult(_importDataStore.FdpImportErrorExclusionGet(filter));
        }

        public async Task<PagedResults<FdpImportErrorExclusion>> ListFdpIgnoredExceptions(IgnoredExceptionFilter filter)
        {
            return await Task.FromResult(_importDataStore.FdpImportErrorExclusionGetMany(filter));
        }

        public async Task<FdpImportErrorExclusion> DeleteFdpImportErrorExclusion(FdpImportErrorExclusion fdpImportErrorExclusion)
        {
            return await Task.FromResult(_importDataStore.FdpImportErrorExclusionDelete(fdpImportErrorExclusion));
        }

        private static DataTable GetImportFileAsDataTable(ImportQueue queuedItem, ImportFileSettings settings)
        {
            return ExcelReader.ReadExcelAsDataTable(queuedItem.FilePath, settings);
        }
        private ImportQueue BulkImportDataTableToDataStore(ImportQueue importQueue)
        {
            var importColumn = importQueue.ImportData.Columns.Add("FdpImportId", typeof(Int32));
            var lineNumberColumn = importQueue.ImportData.Columns.Add("LineNumber", typeof(Int32));

            importColumn.SetOrdinal(0);
            lineNumberColumn.SetOrdinal(1);

            var lineNumber = 1;

            foreach (DataRow row in importQueue.ImportData.Rows)
            {
                row[importColumn] = importQueue.ImportId;
                row[lineNumberColumn] = lineNumber++;
            }
            return _importDataStore.ImportQueueBulkImport(importQueue);
        }
        private ImportQueue ProcessImportData(ImportQueue importQueue)
        {
            return _importDataStore.ImportQueueBulkImportProcess(importQueue);
        }

        private ImportQueueDataStore _importDataStore;
        private MarketDataStore _marketDataStore;
        private DerivativeDataStore _derivativeDataStore;
        private FeatureDataStore _featureDataStore;
        private ModelTrimDataStore _trimDataStore;
    }
}
