using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Filters;

namespace FeatureDemandPlanning.DataStore
{
    [Serializable]
    public class ModelDataStore: DataStoreBase
    {
    
        public ModelDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<FdpModel> FdpAvailableModelByMarketGetMany(TakeRateFilter filter)
        {
            var retVal = Enumerable.Empty<FdpModel>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    para.Add("@MarketId", filter.MarketId, DbType.Int32);

                    retVal = conn.Query<FdpModel>("dbo.Fdp_AvailableModelByMarket_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<FdpModel> FdpAvailableModelByMarketGroupGetMany(TakeRateFilter filter)
        {
            IEnumerable<FdpModel> retVal = Enumerable.Empty<FdpModel>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpVolumeHeaderId", filter.TakeRateId, DbType.Int32);
                    para.Add("@MarketGroupId", filter.MarketGroupId, DbType.Int32);

                    retVal = conn.Query<FdpModel>("dbo.Fdp_AvailableModelByMarketGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        /// <summary>
        /// Models the get many.
        /// </summary>
        /// <param name="make">The make.</param>
        /// <param name="prog_Id">The prog_ identifier.</param>
        /// <param name="doc_id">The doc_id.</param>
        /// <returns></returns>
        public IEnumerable<FdpModel> ModelGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpModel> retVal = null;
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();    
					para.Add("@ProgrammeId", filter.ProgrammeId, DbType.Int32);
                    para.Add("@DocumentId", filter.DocumentId, DbType.Int32);
                    retVal = conn.Query<FdpModel>("dbo.Fdp_Model_GetMany", para, commandType: CommandType.StoredProcedure);
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;   
        }

        public IEnumerable<Model.Model> ModelGetManyBlank(string make)
        {
            IEnumerable<Model.Model> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_make", make, dbType: DbType.String, size: 50);
                    retVal = conn.Query<Model.Model>("dbo.OXO_Model_GetManyBlank", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }

        public Model.Model ModelGet(int id)
        {
            Model.Model retVal = null;

			using (IDbConnection conn = DbHelper.GetDBConnection())
			{
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<Model.Model>("dbo.OXO_Model_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
        }

        public bool ModelSave(Model.Model obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_Model_New" : "dbo.OXO_Model_Edit");

			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
                    obj.Save(this.CurrentCDSID);

					var para = new DynamicParameters();

                    para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@p_Body_Id", obj.BodyId, dbType: DbType.Int32);
                    para.Add("@p_Engine_Id", obj.EngineId, dbType: DbType.Int32);
                    para.Add("@p_Transmission_Id", obj.TransmissionId, dbType: DbType.Int32);
                    para.Add("@p_Trim_Id", obj.TrimId, dbType: DbType.Int32);
                    para.Add("@p_BMC", obj.BMC, dbType: DbType.String, size: 10);
                    para.Add("@p_CoA", obj.CoA, dbType: DbType.String, size: 10);
                    para.Add("@p_KD", obj.KD, dbType: DbType.Boolean);
                    para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
                    para.Add("@p_ChangeSet_Id", obj.ChangesetId, dbType: DbType.Int32);
                    if (obj.IsNew)
                    {
                        para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
                        para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
                    }    
                    para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
                    para.Add("@p_Id", obj.Id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);    

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);
                    obj.Id = para.Get<int>("@p_Id");
			

				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
            
        }

        public bool ModelDelete(int id, int changesetid)
        {
            bool retVal = true;
            
			using (IDbConnection conn = DbHelper.GetDBConnection())
            {
				try
				{
					var para = new DynamicParameters();
					para.Add("@p_Id", id, dbType: DbType.Int32);
                    para.Add("@p_Changeset_Id", changesetid, dbType: DbType.Int32);
                    para.Add("@p_Updated_By", CurrentCDSID, dbType: DbType.String, size: 8);
					conn.Execute("dbo.OXO_Model_Delete", para, commandType: CommandType.StoredProcedure);                   
				}
				catch (Exception ex)
				{
                    Log.Error(ex);
                    throw;
				}
			}

            return retVal;
        }

        public bool ModelGenerateAll(int progid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_veh_prog_id", progid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_GenerateAllModels", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }

        public IEnumerable<Model.Model> GSFModelGetMany(int prog_Id, int doc_id)
        {
            IEnumerable<Model.Model> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_Id", prog_Id, dbType: DbType.Int32);
                    para.Add("@p_doc_Id", doc_id, dbType: DbType.Int32);
                    retVal = conn.Query<Model.Model>("dbo.OXO_GSF_Model_GetMany", para, commandType: CommandType.StoredProcedure);
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