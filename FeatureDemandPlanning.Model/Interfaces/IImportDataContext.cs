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
        Task<ImportSummary> GetImportSummary(ImportQueueFilter filter);
        Task<PagedResults<ImportQueue>> ListImportQueue(ImportQueueFilter filter);
        ImportQueue SaveImportQueue(ImportQueue importItem);

        Task<ImportStatus> GetProcessStatus(ImportQueue importItem);
        ImportResult ProcessImportQueue(ImportQueue queuedItem, ImportFileSettings settings);
        ImportResult ReprocessImportQueue(ImportQueue queuedItem);
        
        Task<ImportError> GetException(ImportQueueFilter filter);
        Task<PagedResults<ImportError>> ListExceptions(ImportQueueFilter filter);

        Task<ImportError> IgnoreException(ImportQueueFilter filter);
        Task<ImportError> IgnoreException(ImportQueueFilter filter, bool reprocess);
        
        Task<ImportError> MapMarket(ImportQueueFilter filter, FdpMarketMapping mapping);

        Task<ImportError> AddDerivative(ImportQueueFilter filter, FdpDerivative derivativeToAdd);
        Task<ImportError> MapDerivative(ImportQueueFilter filter, FdpDerivativeMapping derivativeMapping);

        Task<ImportError> AddFeature(ImportQueueFilter filter, FdpFeature featureToAdd);
        Task<ImportError> AddSpecialFeature(ImportQueueFilter filter, FdpSpecialFeature specialFeature);
        Task<ImportError> MapFeature(ImportQueueFilter filter, FdpFeatureMapping featureMapping);

        Task<ImportError> AddTrim(ImportQueueFilter filter, FdpTrim trimToAdd);
        Task<ImportError> MapTrim(ImportQueueFilter filter, FdpTrimMapping trimMapping);

        Task<IEnumerable<ImportExceptionType>> ListExceptionTypes(ImportQueueFilter filter);

        Task<IEnumerable<ImportStatus>> ListImportStatuses();
        Task<ImportQueue> UpdateStatus(ImportQueueFilter filter);
        Task<ImportError> SaveException(ImportQueueFilter filter);

        Task<FdpImportErrorExclusion> GetFdpImportErrorExclusion(IgnoredExceptionFilter filter);
        Task<PagedResults<FdpImportErrorExclusion>> ListFdpIgnoredExceptions(IgnoredExceptionFilter filter);

        Task<FdpImportErrorExclusion> DeleteFdpImportErrorExclusion(FdpImportErrorExclusion fdpImportErrorExclusion);

        Task<IEnumerable<ImportDerivative>> ListImportDerivatives(ImportQueueFilter importQueueFilter);

        Task<IEnumerable<ImportTrim>> ListImportTrimLevels(ImportQueueFilter importQueueFilter);

        Task<IEnumerable<ImportFeature>> ListImportFeatures(ImportQueueFilter importQueueFilter);

        Task<ImportResult> ProcessTakeRateData(ImportQueue queuedItem);
    }
}
