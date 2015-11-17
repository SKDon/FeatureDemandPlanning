using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using System.Web.Script.Serialization;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;

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

        public IEnumerable<ModelTrim> ModelTrimGetMany(int progId)
        {
            IEnumerable<ModelTrim> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
					retVal = conn.Query<ModelTrim>("dbo.OXO_ModelTrim_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
					AppHelper.LogError("ModelTrimDataStore.ModelTrimGetMany", ex.Message, CurrentCDSID);
				}
			}

            return retVal;   
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
				   AppHelper.LogError("ModelTrimDataStore.ModelTrimGet", ex.Message, CurrentCDSID);
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
					AppHelper.LogError("ModelTrimDataStore.ModelTrimSave", ex.Message, CurrentCDSID);
					retVal = false;
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
					AppHelper.LogError("ModelTrimDataStore.ModelTrimDelete", ex.Message, CurrentCDSID);
					retVal = false;
				}
			}

            return retVal;
        }
        public TrimMapping TrimMappingDelete(TrimMapping trimMapping)
        {
            TrimMapping retVal = new EmptyTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", trimMapping.FdpTrimMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<TrimMapping>("Fdp_TrimMapping_Delete", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ModelTrimDataStore.TrimMappingDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public TrimMapping TrimMappingGet(TrimMapping trimMapping)
        {
            TrimMapping retVal = new EmptyTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpTrimMappingId", trimMapping.FdpTrimMappingId, dbType: DbType.Int32);

                    var results = conn.Query<TrimMapping>("Fdp_TrimMapping_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ModelTrimDataStore.TrimMappingGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public TrimMapping TrimMappingSave(TrimMapping trimMapping)
        {
            TrimMapping retVal = new EmptyTrimMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ImportTrim", trimMapping.ImportTrim, dbType: DbType.String);
                    para.Add("@ProgrammeId", trimMapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", trimMapping.ImportTrim, dbType: DbType.String);
                    para.Add("@TrimId", trimMapping.TrimId, dbType: DbType.Int32);

                    var results = conn.Query<TrimMapping>("Fdp_TrimMapping_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ModelTrimDataStore.TrimMappingSave", ex.Message, CurrentCDSID);
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
                    AppHelper.LogError("ModelTrimDataStore.FdpTrimDelete", ex.Message, CurrentCDSID);
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
                    AppHelper.LogError("ModelTrimDataStore.FdpTrimGet", ex.Message, CurrentCDSID);
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
                    AppHelper.LogError("ModelTrimDataStore.FdpTrimGetMany", ex.Message, CurrentCDSID);
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
                    para.Add("@TrimName", trim.Name, dbType: DbType.String);
                    para.Add("@TrimAbbreviation", trim.Abbreviation, dbType: DbType.String);
                    para.Add("@TrimLevel", trim.Level, dbType: DbType.String);
                    para.Add("@DPCK", trim.DPCK, dbType: DbType.String);

                    retVal = conn.Query<FdpTrim>("dbo.Fdp_Trim_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ModelTrimDataStore.FdpTrimSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }
}