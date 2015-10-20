using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Enumerations;

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
            //var status = new FeatureDemandPlanning.BusinessObjects.ImportStatus() {

            //}

            return await Task.FromResult<ImportQueue>(_importDataStore.ImportQueueGet(importQueueId));
        }

        Task<BusinessObjects.ImportStatus> IImportDataContext.GetProcessStatus(ImportQueue importItem)
        {
            throw new NotImplementedException();
        }

        public async Task<ImportError> Ignore(ImportQueueFilter filter)
        {
            return await Task.FromResult<ImportError>(_importDataStore.ImportErrorIgnore(filter));
        }

        public Task<ImportError> AddMarket(ImportQueueFilter filter, string market)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> MapMarket(ImportQueueFilter filter, string market, string marketToMapTo)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> AddDerivative(ImportQueueFilter filter, BusinessObjects.Model derivativeToAdd)
        {
            throw new NotImplementedException();
        }

        public Task<ImportError> MapDerivative(ImportQueueFilter filter, BusinessObjects.Model derivativeToMap, BusinessObjects.Model derivativeToMapTo)
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
            var results = await Task.FromResult<PagedResults<ImportError>>(
                _importDataStore.ImportErrorGetMany(filter));

            return results;
        }

        private ImportQueueDataStore _importDataStore;


    }
}
