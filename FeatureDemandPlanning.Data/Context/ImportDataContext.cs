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

        public async Task<bool> ProcessImportQueue(ImportQueue importItem)
        {
            return await Task.FromResult<bool>(_importDataStore.ImportQueueProcess(importItem));
        }

        public async Task<bool> ProcessImportQueue()
        {
            return await Task.FromResult<bool>(_importDataStore.ImportQueueProcess());
        }

        private ImportQueueDataStore _importDataStore;

    }
}
