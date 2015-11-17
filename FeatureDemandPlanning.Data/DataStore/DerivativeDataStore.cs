using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.DataStore.DataStore;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Context;

namespace FeatureDemandPlanning.DataStore
{
    public class DerivativeDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public DerivativeDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        #endregion

        public IEnumerable<Derivative> DerivativeGetMany(ProgrammeFilter filter)
        {
            IEnumerable<Derivative> retVal = Enumerable.Empty<Derivative>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ProgrammeId", filter.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@IncludeAllDerivatives", false, dbType: DbType.Boolean);

                    retVal = conn.Query<Derivative>("Fdp_DerivativeMapping_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.DerivativeGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivativeMapping FdpDerivativeMappingDelete(FdpDerivativeMapping derivativeMapping)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeMappingId", derivativeMapping.FdpDerivativeMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Delete", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.DerivativeMappingDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivativeMapping FdpDerivativeMappingGet(DerivativeMappingFilter filter)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeMappingId", filter.DerivativeMappingId.GetValueOrDefault(), dbType: DbType.Int32);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.DerivativeMappingGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public PagedResults<FdpDerivativeMapping> FdpDerivativeMappingGetMany(DerivativeMappingFilter filter)
        {
            PagedResults<FdpDerivativeMapping> retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (!string.IsNullOrEmpty(filter.CarLine))
                    {
                        para.Add("@CarLine", filter.CarLine, dbType: DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.ModelYear))
                    {
                        para.Add("@ModelYear", filter.ModelYear, dbType: DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, dbType: DbType.String);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, dbType: DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.SortDirection != Model.Enumerations.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == Model.Enumerations.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, dbType: DbType.String);
                    }
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpDerivativeMapping>("dbo.Fdp_DerivativeMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpDerivativeMapping>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpDerivativeMapping>();

                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }
                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpDerivativeMappingGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivativeMapping FdpDerivativeMappingSave(FdpDerivativeMapping derivativeMapping)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ImportDerivativeCode", derivativeMapping.ImportDerivativeCode, dbType: DbType.String);
                    para.Add("@ProgrammeId", derivativeMapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", derivativeMapping.Gateway, dbType: DbType.String);
                    para.Add("@DerivativeCode", derivativeMapping.DerivativeCode, dbType: DbType.String);
                    para.Add("@BodyId", derivativeMapping.BodyId, dbType: DbType.Int32);
                    para.Add("@EngineId", derivativeMapping.EngineId, dbType: DbType.Int32);
                    para.Add("@TransmissionId", derivativeMapping.TransmissionId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.DerivativeGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivative FdpDerivativeDelete(FdpDerivative derivativeToDelete)
        {
            FdpDerivative retVal = new EmptyFdpDerivative();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpDerivativeId", derivativeToDelete.FdpDerivativeId.GetValueOrDefault(), dbType: DbType.Int32);

                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpDerivativeDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivative FdpDerivativeGet(DerivativeFilter filter)
        {
            FdpDerivative retVal = new EmptyFdpDerivative();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeId", filter.DerivativeId.GetValueOrDefault(), dbType: DbType.Int32);
                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpDerivativeGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public PagedResults<FdpDerivative> FdpDerivativeGetMany(DerivativeFilter filter)
        {
            PagedResults<FdpDerivative> retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    var totalRecords = 0;
                    var totalDisplayRecords = 0;

                    if (!string.IsNullOrEmpty(filter.CarLine))
                    {
                        para.Add("@CarLine", filter.CarLine, dbType: DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.ModelYear))
                    {
                        para.Add("@ModelYear", filter.ModelYear, dbType: DbType.String);
                    }
                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, dbType: DbType.String);
                    }
                    if (filter.PageIndex.HasValue)
                    {
                        para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.PageSize.HasValue)
                    {
                        para.Add("@PageSize", filter.PageSize.HasValue ? filter.PageSize.Value : 10, dbType: DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
                    }
                    if (filter.SortDirection != Model.Enumerations.SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == Model.Enumerations.SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, dbType: DbType.String);
                    }
                    if (filter.ProgrammeId.HasValue)
                    {
                        para.Add("@ProgrammeId", filter.ProgrammeId, dbType: DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, dbType: DbType.String);
                    }
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpDerivative>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpDerivative>();

                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }
                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpDerivativeGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivative FdpDerivativeSave(FdpDerivative derivative)
        {
            FdpDerivative retVal = new EmptyFdpDerivative();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", derivative.ProgrammeId.GetValueOrDefault(), dbType: DbType.Int32);
                    para.Add("@Gateway", derivative.Gateway, dbType: DbType.String);
                    para.Add("@DerivativeCode", derivative.DerivativeCode, dbType: DbType.String);
                    para.Add("@BodyId", derivative.BodyId.GetValueOrDefault(), dbType: DbType.Int32);
                    para.Add("@EngineId", derivative.EngineId.GetValueOrDefault(), dbType: DbType.String);
                    para.Add("@TransmissionId", derivative.TransmissionId.GetValueOrDefault(), dbType: DbType.Int32);

                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpDerivativeSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }
}
