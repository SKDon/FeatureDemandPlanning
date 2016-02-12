using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class ImportQueueDataStore : DataStoreBase
    {
        public ImportQueueDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }
        public ImportQueue ImportQueueBulkImport(ImportQueue importQueue)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                using (var bulk = new SqlBulkCopy((SqlConnection)conn)
                {
                    BulkCopyTimeout = 60
                })
                {
                    bulk.DestinationTableName = "dbo.Fdp_ImportData";
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(0, "FdpImportId"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(1, "LineNumber"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(2, "Pipeline Code"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(3, "Model Year Desc"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(4, "NSC or Importer Description (Vista Market)"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(5, "Country Description"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(6, "Derivative Code"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(7, "Trim Pack Description"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(8, "Bff Feature Code"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(9, "Feature Description"));
                    bulk.ColumnMappings.Add(new SqlBulkCopyColumnMapping(10, "Count of Specific Order No"));

                    bulk.WriteToServer(importQueue.ImportData);
                    bulk.Close();
                }
            }
            return ImportQueueGet(importQueue.ImportQueueId.GetValueOrDefault());
        }
        public ImportQueue ImportQueueBulkImportProcess(ImportQueue importQueue)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportId", importQueue.ImportId, DbType.Int32);
                    if (importQueue.LineNumber.HasValue)
                    {
                        para.Add("@LineNumber", importQueue.LineNumber, DbType.Int32);
                    }

                    conn.Execute("dbo.Fdp_ImportData_Process", para, commandType: CommandType.StoredProcedure, commandTimeout:600);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return ImportQueueGet(importQueue.ImportQueueId.GetValueOrDefault());
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
                        para.Add("@PageIndex", filter.PageIndex.Value, DbType.Int32);
                        
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, DbType.Int32);
                    }
                    if (filter.ImportStatus != enums.ImportStatus.NotSet)
                    {
                        para.Add("@FdpImportStatusId", (int)filter.ImportStatus, DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, DbType.String, size: 50);
                    }
                    //if (filter.SortIndex.HasValue)
                    //{
                    //    para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    //}
                    para.Add("@SortIndex", filter.SortIndex.GetValueOrDefault(), DbType.Int32);
                    if (filter.SortDirection != enums.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == enums.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }
                    else
                    {
                        para.Add("@SortDirection", "DESC", DbType.String);
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
                    retVal = new PagedResults<ImportQueue>
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<ImportQueue>();
                    
                    foreach (var result in results)
                    {
                        result.ImportType = ImportTypeDataItem.ToImportType(result);
                        result.ImportStatus = ImportStatusDataItem.ToImportStatus(result);
                        //HydrateImportErrors(result, conn);

                        currentPage.Add(ImportQueueDataItem.ToImportQueue(result));
                    }

                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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
                    para.Add("@FdpImportQueueId", importQueueId, DbType.Int32);
                    
                    var result = conn.Query<ImportQueueDataItem>("dbo.Fdp_ImportQueue_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();

                    result.ImportType = ImportTypeDataItem.ToImportType(result);
                    result.ImportStatus = ImportStatusDataItem.ToImportStatus(result);
                    //HydrateImportErrors(result, conn);

                    retVal = ImportQueueDataItem.ToImportQueue(result);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public ImportSummary ImportQueueSummaryGet(int importQueueId)
        {
            ImportSummary retVal = new EmptyImportSummary();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportQueueId", importQueueId, DbType.Int32);

                    var results = conn.Query<ImportSummary>("dbo.Fdp_ImportQueueSummary_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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

                    para.Add("@ImportQueueId", importError.ImportQueueId, DbType.Int32);
                    para.Add("@Error", dbType: DbType.String, size: -1);

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    retVal = importError;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }

        public ImportQueue ImportQueueSave(ImportQueue importQueue)
        {
            ImportQueue retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@CDSId", CurrentCDSID, DbType.String, size: 16);
                    para.Add("@OriginalFileName", importQueue.OriginalFileName, DbType.String);
                    para.Add("@FilePath", importQueue.FilePath, DbType.String);
                    para.Add("@FdpImportTypeId", (int)importQueue.ImportType.ImportTypeDefinition, DbType.Int32);
                    para.Add("@FdpImportStatusId", (int)importQueue.ImportStatus.ImportStatusCode, DbType.Int32);
                    para.Add("@ProgrammeId", importQueue.ProgrammeId, DbType.Int32);
                    para.Add("@Gateway", importQueue.Gateway, DbType.String);
                    para.Add("@DocumentId", importQueue.DocumentId, DbType.Int32);

                    var result = conn
                        .Query<ImportQueueDataItem>("dbo.Fdp_ImportQueue_Save", para, commandType: CommandType.StoredProcedure)
                        .FirstOrDefault();

                    result.ImportType = ImportTypeDataItem.ToImportType(result);
                    result.ImportStatus = ImportStatusDataItem.ToImportStatus(result);
                    //HydrateImportErrors(result, conn);

                    retVal = ImportQueueDataItem.ToImportQueue(result);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;

        }

        public ImportQueue ImportQueueUpdateStatus(ImportQueueFilter filter)
        {
            ImportQueue retVal;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ImportQueueId", filter.ImportQueueId, DbType.Int32);
                    para.Add("@ImportStatusId", (int)filter.ImportStatus, DbType.Int32);
                    if (!string.IsNullOrEmpty(filter.ErrorMessage))
                    {
                        para.Add("@ErrorMessage", filter.ErrorMessage, DbType.String);
                    }
             
                    retVal = conn
                        .Query<ImportQueue>("dbo.Fdp_ImportQueue_UpdateStatus", para, commandType: CommandType.StoredProcedure)
                        .FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public ImportError ImportErrorGet(ImportQueueFilter filter)
        {
            ImportError retVal = new EmptyImportError();

            using (var connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ExceptionId", filter.ExceptionId, DbType.Int32);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportError_Get", para, commandType: CommandType.StoredProcedure);
                    var importErrors = results as IList<ImportError> ?? results.ToList();
                    if (importErrors.Any())
                    {
                        retVal = importErrors.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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

                    para.Add("@FdpImportQueueId", filter.ImportQueueId.Value, DbType.Int32);

                    if (filter.ExceptionType != enums.ImportExceptionType.NotSet)
                    {
                        para.Add("@FdpImportExceptionTypeId", (int)filter.ExceptionType, DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.FilterMessage))
                    {
                        para.Add("@FilterMessage", filter.FilterMessage, DbType.String, size: 50);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, DbType.Int32);
                    }
                    para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 100, DbType.Int32);
                    
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.GetValueOrDefault(), DbType.Int32);
                    }
                    if (filter.SortDirection != enums.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == enums.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }
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
                    retVal = new PagedResults<ImportError>
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
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public ImportError ImportExceptionIgnore(ImportQueueFilter filter)
        {
            ImportError retVal = new EmptyImportError();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ExceptionId", filter.ExceptionId.Value, DbType.Int32);
                    para.Add("@IsExcluded", true, DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportErrorExclusion_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public ImportError ImportExceptionSave(ImportQueueFilter filter)
        {
            ImportError retVal = new EmptyImportError();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportErrorId", filter.ExceptionId.Value, DbType.Int32);
                    para.Add("@IsExcluded", true, DbType.Boolean);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = connection.Query<ImportError>("dbo.Fdp_ImportError_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public IEnumerable<ImportExceptionType> ImportExceptionTypeGetMany(ImportQueueFilter filter)
        {
            var results = Enumerable.Empty<ImportExceptionType>();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportQueueId", filter.ImportQueueId.Value, DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    results = connection.Query<ImportExceptionType>("dbo.Fdp_ImportErrorType_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return results;
        }
        public IEnumerable<ImportStatus> ImportStatusGetMany()
        {
            var retVal = new List<ImportStatus>();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    var results = connection.Query<ImportStatusDataItem>("dbo.Fdp_ImportStatus_GetMany", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        foreach (var result in results)
                        {
                            retVal.Add(new ImportStatus
                            {
                                ImportStatusCode = (enums.ImportStatus)result.FdpImportStatusId,
                                Status = result.Status,
                                Description = result.Description
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public FdpImportErrorExclusion FdpImportErrorExclusionDelete(FdpImportErrorExclusion fdpImportErrorExclusion)
        {
            FdpImportErrorExclusion retVal = new EmptyFdpImportErrorExclusion();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportErrorExclusionId", fdpImportErrorExclusion.FdpImportErrorExclusionId.GetValueOrDefault(), DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpImportErrorExclusion>("Fdp_ImportErrorExclusion_Delete", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpImportErrorExclusion FdpImportErrorExclusionGet(IgnoredExceptionFilter filter)
        {
            FdpImportErrorExclusion retVal = new EmptyFdpImportErrorExclusion();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpImportErrorExclusionId", filter.IgnoredExceptionId.GetValueOrDefault(), DbType.Int32);

                    var results = conn.Query<FdpImportErrorExclusion>("Fdp_ImportErrorExclusion_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public PagedResults<FdpImportErrorExclusion> FdpImportErrorExclusionGetMany(IgnoredExceptionFilter filter)
        {
            PagedResults<FdpImportErrorExclusion> retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (!string.IsNullOrEmpty(filter.CarLine))
                    {
                        para.Add("@CarLine", filter.CarLine, DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.ModelYear))
                    {
                        para.Add("@ModelYear", filter.ModelYear, DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, DbType.String);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, DbType.Int32);
                    }
                    if (filter.SortDirection != enums.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == enums.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpImportErrorExclusion>("dbo.Fdp_ImportErrorExclusion_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpImportErrorExclusion>
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpImportErrorExclusion>();

                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }
                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        private void HydrateImportErrors(ImportQueueDataItem importQueue, IDbConnection connection)
        {
            var para = new DynamicParameters();
            para.Add("@FdpImportQueueId", importQueue.ImportQueueId, DbType.Int32);

            importQueue.Errors = connection.Query<ImportError>("dbo.Fdp_ImportError_GetMany", para, commandType: CommandType.StoredProcedure);
        }
    }
    internal class ImportStatusDataItem : ImportStatus
    {
        public int FdpImportStatusId { get; set; }

        public static ImportStatus ToImportStatus(ImportQueueDataItem dataItem)
        {
            return new ImportStatus
            {
                ImportStatusCode = (enums.ImportStatus)dataItem.FdpImportStatusId,
                Status = dataItem.Status
            };
        }
    }
    internal class ImportTypeDataItem : ImportType
    {
        public int FdpImportTypeId { get; set; }

        public static ImportType ToImportType(ImportQueueDataItem dataItem)
        {
            return new ImportType
            {
                ImportTypeDefinition = (enums.ImportType)dataItem.FdpImportTypeId,
                Type = dataItem.Type
            };
        }
    }
    internal class ImportQueueDataItem : ImportQueue
    {
        public int FdpImportQueueId { get; set; }
        public int FdpImportId { get; set; }
        public int FdpImportStatusId { get; set; }
        public string Status { get; set; }
        public int FdpImportTypeId { get; set; }
        public string Type { get; set; }

        public static ImportQueue ToImportQueue(ImportQueueDataItem dataItem)
        {
            return new ImportQueue
            {
                ImportQueueId = dataItem.FdpImportQueueId,
                ImportId = dataItem.FdpImportId,
                CreatedOn = dataItem.CreatedOn,
                CreatedBy = dataItem.CreatedBy,
                UpdatedOn = dataItem.UpdatedOn,
                OriginalFileName = dataItem.OriginalFileName,
                FilePath = dataItem.FilePath,
                ImportStatus = dataItem.ImportStatus,
                ImportType = dataItem.ImportType,
                Errors = dataItem.Errors,
                ProgrammeId = dataItem.ProgrammeId,
                Gateway = dataItem.Gateway,
                Document = dataItem.Document,
                VehicleName = dataItem.VehicleName,
                VehicleAKA = dataItem.VehicleAKA,
                ModelYear = dataItem.ModelYear,
                HasErrors = dataItem.HasErrors,
                ErrorCount = dataItem.ErrorCount,
                Error = dataItem.Error
            };
        }
    }
}
