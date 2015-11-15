using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
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

        Task<ImportError> IgnoreException(ImportQueueFilter filter);

        Task<ImportError> AddMarket(ImportQueueFilter filter, string market);
        Task<ImportError> MapMarket(ImportQueueFilter filter, string market, string marketToMapTo);

        Task<ImportError> AddDerivative(ImportQueueFilter filter, Model derivativeToAdd);
        Task<ImportError> MapDerivative(ImportQueueFilter filter,
                                        Model derivativeToMap,
                                        Model derivativeToMapTo);

        Task<ImportError> AddFeature(ImportQueueFilter filter, Feature featureToAdd);
        Task<ImportError> MapFeature(ImportQueueFilter filter, Feature featureToMap, Feature featureToMapTo);

        Task<IEnumerable<ImportExceptionType>> ListExceptionTypes(ImportQueueFilter filter);

        Task<IEnumerable<ImportStatus>> ListImportStatuses();
    }
}
