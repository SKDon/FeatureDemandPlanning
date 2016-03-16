using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.DataStore
{
    public class ModelTrimDataStore: DataStoreBase
    {
        public ModelTrimDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public Programme Programme(ModelTrim trim)
        {
            ProgrammeDataStore ds = new ProgrammeDataStore("system");
            Programme retVal = new Programme();

            retVal = ds.ProgrammeGet(trim.ProgrammeId);
            return retVal;
        }

        public IEnumerable<FdpTrimMapping> ModelTrimGetMany(TrimFilter filter)
        {
            filter.PageSize = 1000;
            filter.IncludeAllTrim = true;

            var trim = FdpTrimMappingGetMany(filter);
            if (trim == null || trim.CurrentPage == null || !trim.CurrentPage.Any())
            {
                return Enumerable.Empty<FdpTrimMapping>();
            }

            return trim.CurrentPage.Where(d => !d.FdpTrimMappingId.HasValue);
        }

        public IEnumerable<FdpTrimMapping> ModelTrimOxoTrimGetMany(TrimFilter filter)
        {
            filter.PageSize = 1000;
            
            var trim = FdpTrimMappingGetMany(filter);
            if (trim == null || trim.CurrentPage == null || !trim.CurrentPage.Any())
            {
                return Enumerable.Empty<FdpTrimMapping>();
            }

            return trim.CurrentPage.Where(d => !d.FdpTrimMappingId.HasValue);
        }

        public ModelTrim ModelTrimGet(int id)
        {
            ModelTrim retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					retVal = conn.Query<ModelTrim>("dbo.OXO_ModelTrim_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
        }

        public bool ModelTrimSave(ModelTrim obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_ModelTrim_New" : "dbo.OXO_ModelTrim_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    obj.Save(this.CurrentCDSID);

					var para = new DynamicParameters();

					para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
					para.Add("@p_Name", obj.Name, dbType: DbType.String, size: 500);
                    para.Add("@p_Abbreviation", obj.Abbreviation, dbType: DbType.String, size: 50);
					para.Add("@p_Level", obj.Level, dbType: DbType.String, size: 500);
                    para.Add("@p_DPCK", obj.DPCK, dbType: DbType.String, size: 10);
					para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
                    if (obj.IsNew)
                    {
                        para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
                        para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
                    }
                    para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
                    para.Add("@p_Id", obj.Id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
   
					conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

					if (obj.Id == 0)
					{
						obj.Id = para.Get<int>("@p_Id");
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


        public bool ModelTrimDelete(int id)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
					conn.Execute("dbo.OXO_ModelTrim_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
        }
        public FdpTrimMapping TrimMappingDelete(FdpTrimMapping trimMapping)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", trimMapping.FdpTrimMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpTrimMapping>("Fdp_TrimMapping_Delete", para, commandType: CommandType.StoredProcedure);
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
        public FdpTrimMapping TrimMappingGet(FdpTrimMapping trimMapping)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", trimMapping.FdpTrimMappingId, dbType: DbType.Int32);

                    var results = conn.Query<FdpTrimMapping>("Fdp_TrimMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public FdpTrimMapping TrimMappingSave(FdpTrimMapping trimMapping)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ImportTrim", trimMapping.ImportTrim, dbType: DbType.String);
                    para.Add("@ProgrammeId", trimMapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@DerivativeCode", trimMapping.BMC, DbType.String);
                    para.Add("@Gateway", trimMapping.Gateway, dbType: DbType.String);
                    if (trimMapping.TrimId.HasValue)
                    {
                        para.Add("@TrimId", trimMapping.TrimId.Value, dbType: DbType.Int32);
                    }
                    if (trimMapping.FdpTrimId.HasValue)
                    {
                        para.Add("@FdpTrimId", trimMapping.FdpTrimId, DbType.Int32);
                    }

                    var results = conn.Query<FdpTrimMapping>("Fdp_TrimMapping_Save", para, commandType: CommandType.StoredProcedure);
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
        public FdpTrim FdpTrimDelete(int fdpTrimId)
        {
            FdpTrim retVal = new EmptyFdpTrim();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpTrimId", fdpTrimId, dbType: DbType.Int32);

                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpTrim FdpTrimGet(int fdpTrimId)
        {
            FdpTrim retVal = new EmptyFdpTrim();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimId", fdpTrimId, dbType: DbType.Int32);
                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<FdpTrim> FdpTrimGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpTrim> retVal = Enumerable.Empty<FdpTrim>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", filter.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", filter.Gateway, dbType: DbType.String);

                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpTrim FdpTrimSave(FdpTrim trim)
        {
            FdpTrim retVal = new EmptyFdpTrim();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", trim.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", trim.Gateway, dbType: DbType.String);
                    para.Add("@DerivativeCode", trim.BMC, DbType.String);
                    para.Add("@TrimName", trim.Name, dbType: DbType.String);
                    para.Add("@TrimAbbreviation", trim.Abbreviation, dbType: DbType.String);
                    para.Add("@TrimLevel", trim.Level, dbType: DbType.String);
                    para.Add("@DPCK", trim.DPCK, dbType: DbType.String);

                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public FdpTrim FdpTrimDelete(FdpTrim trimToDelete)
        {
            FdpTrim retVal = new EmptyFdpTrim();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpTrimId", trimToDelete.FdpTrimId.GetValueOrDefault(), dbType: DbType.Int32);

                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public FdpTrim FdpTrimGet(TrimFilter filter)
        {
            FdpTrim retVal = new EmptyFdpTrim();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimId", filter.TrimId.GetValueOrDefault(), dbType: DbType.Int32);
                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public PagedResults<FdpTrim> FdpTrimGetMany(TrimFilter filter)
        {
            PagedResults<FdpTrim> retVal = null;

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

                    var results = conn.Query<FdpTrim>("dbo.Fdp_Trim_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpTrim>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpTrim>();

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

        public FdpTrimMapping FdpTrimMappingDelete(FdpTrimMapping trimMappingToDelete)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", trimMappingToDelete.FdpTrimMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpTrimMapping>("Fdp_TrimMapping_Delete", para, commandType: CommandType.StoredProcedure);
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

        public FdpTrimMapping FdpTrimMappingGet(TrimMappingFilter filter)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", filter.TrimMappingId.GetValueOrDefault(), dbType: DbType.Int32);

                    var results = conn.Query<FdpTrimMapping>("Fdp_TrimMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public PagedResults<FdpTrimMapping> FdpTrimMappingGetMany(TrimFilter filter)
        {
            PagedResults<FdpTrimMapping> retVal = null;

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
                    if (!string.IsNullOrEmpty(filter.Dpck))
                    {
                        para.Add("@DPCK", filter.Dpck, DbType.String);
                    }
                    if (filter.IncludeAllTrim)
                    {
                        para.Add("@IncludeAllTrim", filter.IncludeAllTrim, DbType.Boolean);
                    }
                    if (filter.OxoTrimOnly)
                    {
                        para.Add("@OxoTrimOnly", filter.OxoTrimOnly, DbType.Boolean);
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

                    var results = conn.Query<FdpTrimMapping>("dbo.Fdp_TrimMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpTrimMapping>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = results.ToList();

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
        public FdpTrimMapping FdpTrimMappingCopy(FdpTrimMapping trimMappingToCopy, IEnumerable<string> gateways)
        {
            FdpTrimMapping retVal = new EmptyFdpTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpTrimMappingId", trimMappingToCopy.FdpTrimMappingId, DbType.Int32);
                    para.Add("@Gateways", gateways.ToCommaSeperatedList(), DbType.String);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var rows = conn.Execute("Fdp_TrimMapping_Copy", para, commandType: CommandType.StoredProcedure);

                    retVal = FdpTrimMappingGet(new TrimMappingFilter() { TrimMappingId = trimMappingToCopy.FdpTrimMappingId });
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public PagedResults<OxoTrim> FdpOxoTrimGetMany(TrimMappingFilter filter)
        {
            var results = FdpTrimMappingGetMany(filter);
            var page = results.CurrentPage.Select(result => new OxoTrim(result)).ToList();
            return new PagedResults<OxoTrim>
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

        public OxoTrim DpckUpdate(OxoTrim trim)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);

                    para.Add("@DocumentId", trim.DocumentId, DbType.Int32);
                    para.Add("@TrimId", trim.TrimId, DbType.Int32);
                    para.Add("@DPCK", trim.DPCK, DbType.String);


                    var results = conn.Query<OxoTrim>("Fdp_Dpck_Update", para, commandType: CommandType.StoredProcedure);
                    var trimLevels = results as IList<OxoTrim> ?? results.ToList();
                    if (results != null && trimLevels.Any())
                    {
                        trim = trimLevels.First();
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return trim;
        }
    }
}