using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using System.Data.SqlClient;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Context;

namespace FeatureDemandPlanning.DataStore
{
    public class MarketDataStore : DataStoreBase
    {
        public MarketDataStore(string cdsid) : base(cdsid)
        {
        }
        public IEnumerable<Market> MarketGetMany()
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketGetMany(int progId, int docId)
        {
            IEnumerable<Market> retVal = Enumerable.Empty<Market>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Programme_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketGroupMarketGetMany()
        {
            IEnumerable<Market> retVal = Enumerable.Empty<Market>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_MarketGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGroupGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketAvailableGetMany(int progId)
        {
            IEnumerable<Market> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Market_AvailableGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketAvailableGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public IEnumerable<Market> FdpMarketAvailableGetMany()
        {
            IEnumerable<Market> retVal = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    retVal = conn.Query<Market>("dbo.Fdp_Market_AvailableGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.FdpMarketAvailableGetMany", ex.Message, CurrentCDSID);
                }

            }
            return retVal;
        }
        public Market MarketGet(int id)
        {
            Market retVal = new EmptyMarket();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    var results = conn.Query<Market>("dbo.OXO_Market_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.MarketGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<Market> TopMarketGetMany()
        {
            IEnumerable<Market> retVal = Enumerable.Empty<Market>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGetMany::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGetMany::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }

            }
            return retVal;
        }

        public Market TopMarketGet(int marketId)
        {
            Market retVal = new EmptyMarket();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketId, dbType: DbType.Int32);
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGet::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketGet::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }
            return retVal;
        }

        public Market TopMarketSave(Market marketToSave)
        {
            Market retVal = new EmptyMarket();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToSave.Id, dbType: DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, dbType: DbType.String);
                    para.Add("@TopMarketId", null, dbType: DbType.Int32, direction: ParameterDirection.Output);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_New", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketSave::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketSave::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }
            return retVal;
        }
        public Market TopMarketDelete(Market marketToDelete)
        {
            Market retVal = new EmptyMarket();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToDelete.Id, dbType: DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, dbType: DbType.String);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketDelete::0", sx.Message, CurrentCDSID);
                    throw new ApplicationException(sx.Message);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.TopMarketDelete::1", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }
            return retVal;
        }
        public PagedResults<FdpMarketMapping> FdpMarketMappingGetMany(MarketFilter filter)
        {
            PagedResults<FdpMarketMapping> retVal = null;

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

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpMarketMapping>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpMarketMapping>();

                    foreach (var result in results)
                    {
                        currentPage.Add(result);
                    }
                    retVal.CurrentPage = currentPage;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpMarketMappingGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingDelete(FdpMarketMapping mapping)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpMarketMappingId", mapping.FdpMarketMappingId, dbType: DbType.String);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_Delete", para, commandType: CommandType.StoredProcedure);
                    if (!results.Any())
                    {
                        return retVal;
                    }
                    retVal = results.First();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.FdpMarketMappingDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingSave(FdpMarketMapping mapping)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ImportMarket", mapping.ImportMarket, dbType: DbType.String);
                    para.Add("@MappedMarketId", mapping.MarketId, dbType: DbType.Int32);
                    if (!mapping.IsGlobalMapping)
                    {
                        para.Add("@ProgrammeId", mapping.ProgrammeId, dbType: DbType.Int32);
                        para.Add("@Gateway", mapping.Gateway, dbType: DbType.String);
                    }
                    para.Add("@IsGlobalMapping", mapping.IsGlobalMapping, dbType: DbType.Boolean);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_Save", para, commandType: CommandType.StoredProcedure);
                    if (!results.Any())
                    {
                        return retVal;
                    }
                    retVal = results.First();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("MarketDataStore.FdpMarketMappingSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }

            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingGet(MarketMappingFilter filter)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpDerivativeMappingId", filter.MarketMappingId.GetValueOrDefault(), dbType: DbType.Int32);

                    var results = conn.Query<FdpMarketMapping>("Fdp_MarketMapping_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.FdpMarketMappingGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }
}