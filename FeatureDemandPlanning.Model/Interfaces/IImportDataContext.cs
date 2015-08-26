using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    /// <summary>
    /// Contract defining the methods available on the import data context
    /// </summary>
    public interface IImportDataContext
    {
        Task<ImportQueue> GetImportQueue(ImportQueueFilter filter);
        Task<PagedResults<ImportQueue>> ListImportQueue(ImportQueueFilter filter);
        Task<ImportQueue> SaveImportQueue(ImportQueue importItem);
        Task<ImportError> SaveError(ImportError importError);
        Task<bool> ProcessImportQueue(ImportQueue importItem);
        Task<bool> ProcessImportQueue();
    }
}
