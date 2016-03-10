using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class DerivativeDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public DerivativeDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }

        #endregion

        public IEnumerable<Derivative> DerivativeGetMany(DerivativeFilter filter)
        {
            filter.PageSize = 1000;
            filter.IncludeAllDerivatives = true;

            var derivatives = FdpDerivativeMappingGetMany(filter);
            if (derivatives == null || derivatives.CurrentPage == null || !derivatives.CurrentPage.Any())
            {
                return Enumerable.Empty<Derivative>();
            }

            return derivatives.CurrentPage.Where(d => d.IsMappedDerivative == false);
        }
        public FdpDerivativeMapping FdpDerivativeMappingDelete(FdpDerivativeMapping derivativeMapping)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeMappingId", derivativeMapping.FdpDerivativeMappingId, DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Delete", para, commandType: CommandType.StoredProcedure);
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
        public FdpDerivativeMapping FdpDerivativeMappingGet(DerivativeMappingFilter filter)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeMappingId", filter.DerivativeMappingId.GetValueOrDefault(), DbType.Int32);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public PagedResults<FdpDerivativeMapping> FdpDerivativeMappingGetMany(DerivativeFilter filter)
        {
            PagedResults<FdpDerivativeMapping> retVal = null;

            using (var conn = DbHelper.GetDBConnection())
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
                        para.Add("@PageSize", filter.PageSize.Value, DbType.Int32);
                    }
                    if (filter.SortIndex.HasValue)
                    {
                        para.Add("@SortIndex", filter.SortIndex.Value, DbType.Int32);
                    }
                    if (filter.SortDirection != SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }
                    if (filter.IncludeAllDerivatives)
                    {
                        para.Add("@IncludeAllDerivatives", true, DbType.Boolean);
                    }
                    if (filter.OxoDerivativesOnly)
                    {
                        para.Add("@OxoDerivativesOnly", filter.OxoDerivativesOnly, DbType.Boolean);
                    }
                    para.Add("@TotalPages", DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpDerivativeMapping>("dbo.Fdp_DerivativeMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpDerivativeMapping>
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
                    Log.Error(ex);
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

                    para.Add("@ImportDerivativeCode", derivativeMapping.ImportDerivativeCode, DbType.String);
                    para.Add("@ProgrammeId", derivativeMapping.ProgrammeId, DbType.Int32);
                    para.Add("@Gateway", derivativeMapping.Gateway, DbType.String);
                    if (!string.IsNullOrEmpty(derivativeMapping.DerivativeCode))
                    {
                        para.Add("@DerivativeCode", derivativeMapping.DerivativeCode, DbType.String);
                    }
                    para.Add("@BodyId", derivativeMapping.BodyId, DbType.Int32);
                    para.Add("@EngineId", derivativeMapping.EngineId, DbType.Int32);
                    para.Add("@TransmissionId", derivativeMapping.TransmissionId, DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpDerivativeMapping>("Fdp_DerivativeMapping_Save", para, commandType: CommandType.StoredProcedure);
                    var fdpDerivativeMappings = results as IList<FdpDerivativeMapping> ?? results.ToList();
                    if (fdpDerivativeMappings.Any())
                    {
                        retVal = fdpDerivativeMappings.First();
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
        public FdpDerivative FdpDerivativeDelete(FdpDerivative derivativeToDelete)
        {
            FdpDerivative retVal = new EmptyFdpDerivative();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpDerivativeId", derivativeToDelete.FdpDerivativeId.GetValueOrDefault(), DbType.Int32);

                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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
                    para.Add("@FdpDerivativeId", filter.DerivativeId.GetValueOrDefault(), DbType.Int32);
                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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
                    if (filter.SortDirection != SortDirection.NotSet)
                    {
                        var direction = filter.SortDirection == SortDirection.Descending ? "DESC" : "ASC";
                        para.Add("@SortDirection", direction, DbType.String);
                    }
                    if (filter.ProgrammeId.HasValue)
                    {
                        para.Add("@ProgrammeId", filter.ProgrammeId, DbType.Int32);
                    }
                    if (!string.IsNullOrEmpty(filter.Gateway))
                    {
                        para.Add("@Gateway", filter.Gateway, DbType.String);
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
                    retVal = new PagedResults<FdpDerivative>
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
                    Log.Error(ex);
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
                    para.Add("@ProgrammeId", derivative.ProgrammeId.GetValueOrDefault(), DbType.Int32);
                    para.Add("@Gateway", derivative.Gateway, DbType.String);
                    para.Add("@DerivativeCode", derivative.DerivativeCode, DbType.String);
                    para.Add("@BodyId", derivative.BodyId.GetValueOrDefault(), DbType.Int32);
                    para.Add("@EngineId", derivative.EngineId.GetValueOrDefault(), DbType.String);
                    para.Add("@TransmissionId", derivative.TransmissionId.GetValueOrDefault(), DbType.Int32);

                    retVal = conn.Query<FdpDerivative>("dbo.Fdp_Derivative_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpDerivativeMapping FdpDerivativeMappingCopy(FdpDerivativeMapping derivativeMappingToCopy, IEnumerable<string> gateways)
        {
            FdpDerivativeMapping retVal = new EmptyFdpDerivativeMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpDerivativeMappingId", derivativeMappingToCopy.FdpDerivativeMappingId, DbType.Int32);
                    para.Add("@Gateways", gateways.ToCommaSeperatedList(), DbType.String);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var rows = conn.Execute("Fdp_DerivativeMapping_Copy", para, commandType: CommandType.StoredProcedure);

                    retVal = FdpDerivativeMappingGet(new DerivativeMappingFilter { DerivativeMappingId = derivativeMappingToCopy.FdpDerivativeMappingId });
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public BmcMapping GetMappedBmc(DerivativeFilter filter)
        {
            BmcMapping mapping = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ProgrammeId", filter.ProgrammeId, DbType.Int32);
                    para.Add("@Gateway", filter.Gateway, DbType.String);
                    para.Add("@ImportBMC", filter.Bmc, DbType.String);

                    var results = conn.Query<BmcMapping>("Fdp_Derivative_GetMappedBMC", para, commandType: CommandType.StoredProcedure);
                    var bmcMappings = results as IList<BmcMapping> ?? results.ToList();
                    if (results != null && bmcMappings.Any())
                    {
                        mapping = bmcMappings.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return mapping;
        }

        public PagedResults<OxoDerivative> FdpOxoDerivativeGetMany(DerivativeMappingFilter filter)
        {
            var results = FdpDerivativeMappingGetMany(filter);
            var page = results.CurrentPage.Select(result => new OxoDerivative(result)).ToList();
            return new PagedResults<OxoDerivative>
            {
                PageIndex = results.PageIndex,
                PageSize = results.PageSize,
                TotalDisplayRecords = results.TotalDisplayRecords,
                TotalFail = results.TotalFail,
                TotalRecords = results.TotalRecords,
                TotalSuccess = results.TotalSuccess,
                CurrentPage = page
            };

        }

        public OxoDerivative BrochureModelCodeUpdate(OxoDerivative derivative)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@DocumentId", derivative.DocumentId, DbType.Int32);
                    para.Add("@BodyId", derivative.BodyId, DbType.String);
                    para.Add("@EngineId", derivative.EngineId, DbType.Int32);
                    para.Add("@TransmissionId", derivative.TransmissionId, DbType.Int32);
                    para.Add("@DerivativeCode", derivative.DerivativeCode, DbType.String);

                    var results = conn.Query<OxoDerivative>("Fdp_BrochureModelCode_Update", para, commandType: CommandType.StoredProcedure);
                    var derivatives = results as IList<OxoDerivative> ?? results.ToList();
                    if (results != null && derivatives.Any())
                    {
                        derivative = derivatives.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return derivative;
        }
    }
}
