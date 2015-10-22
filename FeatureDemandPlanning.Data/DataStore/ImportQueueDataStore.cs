using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Dapper;
using enums = FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.DataStore.DataStore;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;

namespace FeatureDemandPlanning.DataStore
{
    public class ImportQueueDataStore : DataStoreBase
    {
        public ImportQueueDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public PagedResults<ImportQueue> ImportQueueGetMany(ImportQueueFilter filter)
        {
            PagedResults<ImportQueue> retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                        
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, dbType: DbType.Int32);
                    }


                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<ImportQueueDataItem>("dbo.Fdp_ImportQueue_GetMany", para, commandType: CommandType.StoredProcedure);
                    
                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<ImportQueue>() 
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<ImportQueue>();
                    
                    foreach (var result in results)
                    {
                        HydrateImportType(result, conn);
                        HydrateImportStatus(result, conn);
                        HydrateImportErrors(result, conn);

                        currentPage.Add(HydrateImportQueue(result, conn));
                    }

                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportQueueGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        public ImportQueue ImportQueueGet(int importQueueId)
        {
            ImportQueue retVal = new EmptyImportQueue();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ImportQueueId", importQueueId, dbType: DbType.Int32);
                    
                    var result = conn.Query<ImportQueueDataItem>("dbo.Fdp_ImportQueue_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();

                    HydrateImportType(result, conn);
                    HydrateImportStatus(result, conn);
                    HydrateImportErrors(result, conn);

                    retVal = HydrateImportQueue(result, conn);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ConfigurationDataStore.ImportQueueGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        public ImportError ImportErrorSave(ImportError importError)
        {
            ImportError retVal = null;
            string procName = "dbo.ImportQueue_Edit";

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ImportQueueId", importError.ImportQueueId, dbType: DbType.Int32);
                    para.Add("@Error", dbType: DbType.String, size: -1);

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    retVal = importError;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportQueueSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        public ImportQueue ImportQueueSave(ImportQueue importQueue)
        {
            ImportQueue retVal = null;
            string procName = "dbo.ImportQueue_Save";

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ImportQueueId", importQueue.ImportQueueId, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
                    para.Add("@SystemUser", CurrentCDSID, dbType: DbType.String, size: 16);
                    para.Add("@FilePath", importQueue.FilePath, dbType: DbType.String, size: -1);
                    para.Add("@ImportTypeId", (int)importQueue.ImportType.ImportTypeDefinition, dbType: DbType.Int32);
                    para.Add("@ImportStatusId", (int)importQueue.ImportStatus.ImportStatusCode, dbType: DbType.Int32);

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    if (!importQueue.ImportQueueId.HasValue)
                    {
                        importQueue.ImportQueueId = para.Get<int?>("@ImportQueueId");
                    }

                    // Repopulate the object following save
                    
                    para = new DynamicParameters();
                    para.Add("@ImportQueueId", importQueue.ImportQueueId, dbType: DbType.Int32);

                    var result = conn.Query<ImportQueueDataItem>("dbo.Fdp_ImportQueue_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();

                    HydrateImportType(result, conn);
                    HydrateImportStatus(result, conn);
                    //HydrateImportErrors(result, conn);

                    // As we have used an interim object here and don't want to return some of the elements of that object
                    // create a new ImportQueue instance and return
                    retVal = HydrateImportQueue(result, conn);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportQueueSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;

        }

        public ImportResult ImportQueueProcess()
        {
            var result = new ImportResult();
            string procName = "dbo.Fdp_Import_Process";

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportQueueProcess::0", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return result;
        }

        public ImportResult ImportQueueProcess(ImportQueue importItem)
        {
            var result = new ImportResult();
            string procName = "dbo.Fdp_Import_Process";

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ImportQueueId", importItem.ImportQueueId, dbType: DbType.Int32);
               
                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);  
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportQueueProcess::1", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return result;
        }

        public ImportError ImportErrorGet(ImportQueueFilter filter)
        {
            ImportError retVal = new EmptyImportError();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ExceptionId", filter.ExceptionId.Value, dbType: DbType.Int32);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportError_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportErrorGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        public PagedResults<ImportError> ImportErrorGetMany(ImportQueueFilter filter)
        {
            PagedResults<ImportError> retVal = null;

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;
                    var totalImportedRecords = 0;
                    var totalFailedRecords = 0;

                    para.Add("@ImportQueueId", filter.ImportQueueId.Value, dbType: DbType.Int32);

                    if (filter.ExceptionType != enums.ImportExceptionType.NotSet)
                    {
                        para.Add("@FdpImportExceptionTypeId", (int)filter.ExceptionType, dbType: DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, dbType: DbType.String, size: 50);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                    }
                    para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 100, dbType: DbType.Int32);
                    
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    }
                    para.Add("@SortDirection", (int)filter.SortDirection, dbType: DbType.Int32);
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalImportedRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalFailedRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportError_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                        totalImportedRecords = para.Get<int>("@TotalImportedRecords");
                        totalFailedRecords = para.Get<int>("@TotalFailedRecords");
                    }
                    retVal = new PagedResults<ImportError>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        TotalSuccess = totalImportedRecords,
                        TotalFail = totalFailedRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    retVal.CurrentPage = results;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportErrorGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        public ImportError ImportErrorIgnore(ImportQueueFilter filter)
        {
            ImportError retVal = new EmptyImportError();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ExceptionId", filter.ExceptionId.Value, dbType: DbType.Int32);
                    para.Add("@IsExcluded", true, dbType:DbType.Int32);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportError_Ignore", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ImportQueueDataStore.ImportErrorIgnore", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }

        private void HydrateImportErrors(ImportQueueDataItem importQueue, IDbConnection connection)
        {
            var para = new DynamicParameters();
            para.Add("@ImportQueueId", importQueue.ImportQueueId, dbType: DbType.Int32);

            importQueue.Errors = connection.Query<ImportError>("dbo.ImportError_GetMany", para, commandType: CommandType.StoredProcedure);
        }

        private void HydrateImportType(ImportQueueDataItem importQueue, IDbConnection connection)
        {
            var para = new DynamicParameters();
            para.Add("@ImportTypeId", importQueue.ImportTypeId, dbType: DbType.Int32);

            var type = connection.Query<ImportType>("dbo.ImportType_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
            if (type != null)
                importQueue.ImportType = type;
        }

        private void HydrateImportStatus(ImportQueueDataItem importQueue, IDbConnection connection)
        {
            var para = new DynamicParameters();
            para.Add("@ImportStatusId", importQueue.ImportStatusId, dbType: DbType.Int32);

            var status = connection.Query<ImportStatus>("dbo.ImportStatus_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
            if (status != null)
                importQueue.ImportStatus = status;
        }

        private ImportQueue HydrateImportQueue(ImportQueueDataItem importQueue, IDbConnection connection)
        {
            return new ImportQueue()
            {
                ImportQueueId = importQueue.ImportQueueId,
                CreatedOn = importQueue.CreatedOn,
                CreatedBy = importQueue.CreatedBy,
                UpdatedOn = importQueue.UpdatedOn,
                FilePath = importQueue.FilePath,
                ImportStatus = importQueue.ImportStatus,
                ImportType = importQueue.ImportType,
                Errors = importQueue.Errors,
                ProgrammeId = importQueue.ProgrammeId,
                Gateway = importQueue.Gateway
            };
        }

        private ImportStatus HydrateImportStatus(ImportStatusDataItem importStatus, IDbConnection connection)
        {
            return new ImportStatus()
            {
                ImportStatusCode = (enums.ImportStatus)importStatus.ImportStatusId,
                Status = importStatus.Status,
                Description = importStatus.Description
            };
        }

        private ImportType HydrateImportType(ImportTypeDataItem importType, IDbConnection connection)
        {
            return new ImportType()
            {
                ImportTypeDefinition = (enums.ImportType)importType.ImportTypeId,
                Type = importType.Type,
                Description = importType.Description
            };
        }

        private class ImportQueueDataItem : ImportQueue
        {
            public int ImportStatusId { get; set; }
            public string StatusCode { get; set; }
            public int ImportTypeId { get; set; }
            public string Type { get; set; }
            public int ProgrammeId { get; set; }
            public string Gateway { get; set; }
        }

        private class ImportStatusDataItem
        {
            public int ImportStatusId { get; set; }
            public string Status { get; set; }
            public string Description { get; set; }
        }

        private class ImportTypeDataItem
        {
            public int ImportTypeId { get; set; }
            public string Type { get; set; }
            public string Description { get; set; }
        }
    }
}
