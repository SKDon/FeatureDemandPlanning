using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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
        ImportQueue SaveImportQueue(ImportQueue importItem);

        Task<ImportStatus> GetProcessStatus(ImportQueue importItem);
        ImportResult ProcessImportQueue(ImportQueue queuedItem);
        
        Task<ImportError> GetException(ImportQueueFilter filter);
        Task<PagedResults<ImportError>> ListExceptions(ImportQueueFilter filter);

        Task<ImportError> IgnoreException(ImportQueueFilter filter);
        
        Task<ImportError> MapMarket(ImportQueueFilter filter, MarketMapping mapping);

        Task<ImportError> AddDerivative(ImportQueueFilter filter, FdpDerivative derivativeToAdd);
        Task<ImportError> MapDerivative(ImportQueueFilter filter, FdpDerivativeMapping derivativeMapping);

        Task<ImportError> AddFeature(ImportQueueFilter filter, FdpFeature featureToAdd);
        Task<ImportError> AddSpecialFeature(ImportQueueFilter filter, FdpSpecialFeature specialFeature);
        Task<ImportError> MapFeature(ImportQueueFilter filter, FeatureMapping featureMapping);

        Task<ImportError> AddTrim(ImportQueueFilter filter, FdpTrim trimToAdd);
        Task<ImportError> MapTrim(ImportQueueFilter filter, TrimMapping trimMapping);

        Task<IEnumerable<ImportExceptionType>> ListExceptionTypes(ImportQueueFilter filter);

        Task<IEnumerable<ImportStatus>> ListImportStatuses();
        Task<ImportError> SaveException(ImportQueueFilter filter);
    }
}
