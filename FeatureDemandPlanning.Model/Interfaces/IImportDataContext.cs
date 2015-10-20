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

        Task<ImportStatus> GetProcessStatus(ImportQueue importItem);
        Task<ImportResult> ProcessImportQueue(ImportQueue importItem);
        Task<ImportResult> ProcessImportQueue();

        Task<ImportError> GetException(ImportQueueFilter filter);
        Task<PagedResults<ImportError>> ListExceptions(ImportQueueFilter filter);

        Task<ImportError> Ignore(ImportQueueFilter filter);

        Task<ImportError> AddMarket(ImportQueueFilter filter, string market);
        Task<ImportError> MapMarket(ImportQueueFilter filter, string market, string marketToMapTo);

        Task<ImportError> AddDerivative(ImportQueueFilter filter, BusinessObjects.Model derivativeToAdd);
        Task<ImportError> MapDerivative(ImportQueueFilter filter,
                                        BusinessObjects.Model derivativeToMap,
                                        BusinessObjects.Model derivativeToMapTo);

        Task<ImportError> AddFeature(ImportQueueFilter filter, Feature featureToAdd);
        Task<ImportError> MapFeature(ImportQueueFilter filter, Feature featureToMap, Feature featureToMapTo);
    }
}
