using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Helpers;

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
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketGetMany(int progId, int docId)
        {
            var retVal = Enumerable.Empty<Market>();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, DbType.Int32);
                    para.Add("@p_doc_id", docId, DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Programme_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketGetMany(TakeRateFilter filter)
        {
            IEnumerable<Market> retVal;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    
                    retVal = conn.Query<Market>("dbo.Fdp_Market_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        } 
        public IEnumerable<Market> MarketGroupMarketGetMany()
        {
            var retVal = Enumerable.Empty<Market>();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.OXO_Market_MarketGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        }
        public IEnumerable<Market> MarketAvailableGetMany(int progId)
        {
            IEnumerable<Market> retVal = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, DbType.Int32);
                    retVal = conn.Query<Market>("dbo.OXO_Market_AvailableGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        }
        public Market MarketGet(int id)
        {
            Market retVal = new EmptyMarket();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, DbType.Int32);
                    var results = conn.Query<Market>("dbo.OXO_Market_Get", para, commandType: CommandType.StoredProcedure);
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
        public IEnumerable<Market> TopMarketGetMany()
        {
            var retVal = Enumerable.Empty<Market>();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (SqlException sx)
                {
                    Log.Error(sx);
                    throw;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }

            }
            return retVal;
        }

        public Market TopMarketGet(int marketId)
        {
            Market retVal = new EmptyMarket();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketId, DbType.Int32);
                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_GetMany", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    Log.Error(sx);
                    throw;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public Market TopMarketSave(Market marketToSave)
        {
            Market retVal = new EmptyMarket();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToSave.Id, DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, DbType.String);
                    para.Add("@TopMarketId", null, DbType.Int32, ParameterDirection.Output);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_New", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    Log.Error(sx);
                    throw;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public Market TopMarketDelete(Market marketToDelete)
        {
            Market retVal = new EmptyMarket();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@MarketId", marketToDelete.Id, DbType.Int32);
                    para.Add("@CdsId", CurrentCDSID, DbType.String);

                    retVal = conn.Query<Market>("dbo.Fdp_TopMarket_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (SqlException sx)
                {
                    Log.Error(sx);
                    throw;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public PagedResults<FdpMarketMapping> FdpMarketMappingGetMany(MarketFilter filter)
        {
            PagedResults<FdpMarketMapping> retVal = null;

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

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpMarketMapping>
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
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingDelete(FdpMarketMapping mapping)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpMarketMappingId", mapping.FdpMarketMappingId, DbType.String);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_Delete", para, commandType: CommandType.StoredProcedure);
                    if (!results.Any())
                    {
                        return retVal;
                    }
                    retVal = results.First();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingSave(FdpMarketMapping mapping)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ImportMarket", mapping.ImportMarket, DbType.String);
                    para.Add("@MappedMarketId", mapping.MarketId, DbType.Int32);
                    if (!mapping.IsGlobalMapping)
                    {
                        para.Add("@ProgrammeId", mapping.ProgrammeId, DbType.Int32);
                        para.Add("@Gateway", mapping.Gateway, DbType.String);
                    }
                    para.Add("@IsGlobalMapping", mapping.IsGlobalMapping, DbType.Boolean);
                    para.Add("@CDSId", CurrentCDSID, DbType.String);

                    var results = conn.Query<FdpMarketMapping>("dbo.Fdp_MarketMapping_Save", para, commandType: CommandType.StoredProcedure);
                    if (!results.Any())
                    {
                        return retVal;
                    }
                    retVal = results.First();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
        public FdpMarketMapping FdpMarketMappingGet(MarketMappingFilter filter)
        {
            FdpMarketMapping retVal = new EmptyFdpMarketMapping();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpMarketMappingId", filter.MarketMappingId.GetValueOrDefault(), DbType.Int32);

                    var results = conn.Query<FdpMarketMapping>("Fdp_MarketMapping_Get", para, commandType: CommandType.StoredProcedure);
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
    }
}