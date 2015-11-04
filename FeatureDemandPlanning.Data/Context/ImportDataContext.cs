using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class ImportDataContext : BaseDataContext, IImportDataContext
    {
        public ImportDataContext(string cdsId) : base(cdsId)
        {
            _importDataStore = new ImportQueueDataStore(cdsId);
        }

        public async Task<ImportQueue> GetImportQueue(ImportQueueFilter filter)
        {
            if (!filter.ImportQueueId.HasValue)
                throw new ArgumentNullException("ImportQueueId not specified");
            
            return await Task.FromResult<ImportQueue>(_importDataStore.ImportQueueGet(filter.ImportQueueId.Value));
        }

        public async Task<PagedResults<ImportQueue>> ListImportQueue(ImportQueueFilter filter)
        {
            var results = await Task.FromResult<PagedResults<ImportQueue>>(
                _importDataStore.ImportQueueGetMany(filter));
                
            return results;
        }

        public async Task<ImportQueue> SaveImportQueue(ImportQueue importItem)
        {
            return await Task.FromResult<ImportQueue>(_importDataStore.ImportQueueSave(importItem));
        }

        public async Task<ImportError> SaveError(ImportError importError)
        {
            return await Task.FromResult<ImportError>(_importDataStore.ImportErrorSave(importError));
        }

        public async Task<ImportQueue> GetProcessStatus(ImportQueue importItem)
        {
            var importQueueId = importItem.ImportQueueId.GetValueOrDefault();
            //var result = await Task.FromResult<ImportQueue>();
            //var status = new FeatureDemandPlanning..ImportStatus() {

            //}

            return await Task.FromResult<ImportQueue>(_importDataStore.ImportQueueGet(importQueueId));
        }

        Task<Model.ImportStatus> IImportDataContext.GetProcessStatus(ImportQueue importItem)
        {
            throw new NotImplementedException();
        }

        public async Task<ImportError> IgnoreException(ImportQueueFilter filter)
        {
            return await Task.FromResult<ImportError>(_importDataStore.ImportExceptionIgnore(filter));
        }

        public Task<ImportError> AddMarket(ImportQueueFilter filter, string market)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> MapMarket(ImportQueueFilter filter, string market, string marketToMapTo)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> AddDerivative(ImportQueueFilter filter, Model.Model derivativeToAdd)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> MapDerivative(ImportQueueFilter filter, Model.Model derivativeToMap, Model.Model derivativeToMapTo)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> AddFeature(ImportQueueFilter filter, Feature featureToAdd)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> MapFeature(ImportQueueFilter filter, Feature featureToMap, Feature featureToMapTo)
        {
            throw new NotImplementedException();
        }

        public async Task<ImportResult> ProcessImportQueue(ImportQueue importItem)
        {
            return await Task.FromResult<ImportResult>(_importDataStore.ImportQueueProcess(importItem));
        }

        public async Task<ImportResult> ProcessImportQueue()
        {
            return await Task.FromResult<ImportResult>(_importDataStore.ImportQueueProcess());
        }

        public async Task<ImportError> GetException(ImportQueueFilter filter)
        {
            return await Task.FromResult<ImportError>(_importDataStore.ImportErrorGet(filter));
        }

        public async Task<PagedResults<ImportError>> ListExceptions(ImportQueueFilter filter)
        {
            return await Task.FromResult<PagedResults<ImportError>>(
                _importDataStore.ImportErrorGetMany(filter));

        }

        public async Task<IEnumerable<FeatureDemandPlanning.Model.ImportExceptionType>> ListExceptionTypes(ImportQueueFilter filter)
        {
            return await Task.FromResult<IEnumerable<FeatureDemandPlanning.Model.ImportExceptionType>>(
                _importDataStore.ImportExceptionTypeGetMany(filter));
        }

        private ImportQueueDataStore _importDataStore;


    }
}
