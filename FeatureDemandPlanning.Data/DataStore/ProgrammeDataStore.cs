using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class ProgrammeDataStore : DataStoreBase
    {

        public ProgrammeDataStore(string cdsid)
        {
            CurrentCDSID = cdsid;
        }

        public static void PopulateConfiguration(Programme programme)
        {
            var ds = new ProgrammeDataStore("system");
            var obj = ds.ProgrammeGetConfiguration(programme.Id);
            if (obj == null) return;
            programme.Id = obj.Id;
            programme.VehicleName = obj.VehicleName;
            programme.VehicleAKA = obj.VehicleAKA;
            programme.VehicleMake = obj.VehicleMake;
            programme.VehicleDisplayFormat = obj.VehicleDisplayFormat;
            programme.ModelYear = obj.ModelYear;
            programme.PS = obj.PS;
            programme.J1 = obj.J1;
            programme.Notes = obj.Notes;
            programme.ProductManager = obj.ProductManager;
            programme.RSGUID = obj.RSGUID;
            programme.Active = obj.Active;
            programme.AllBodies = obj.AllBodies;
            programme.AllEngines = obj.AllEngines;
            programme.AllTransmissions = obj.AllTransmissions;
            programme.AllTrims = obj.AllTrims;
        }

        public IEnumerable<EngineCodeMapping> EngineCodeMappingGetMany()
        {
            IList<EngineCodeMapping> retVal;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@TotalRecords", null, DbType.Int32, ParameterDirection.Output);

                    var results = conn.Query<EngineCodeMapping>("dbo.Fdp_EngineCode_GetMany", para, commandType: CommandType.StoredProcedure);
                    var totalRecords = para.Get<int?>("@TotalRecords");

                    retVal = new List<EngineCodeMapping>();

                    foreach (var result in results)
                    {
                        result.TotalRecords = totalRecords.Value;
                        retVal.Add(result);
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

        public EngineCodeMapping EngineCodeMappingSave(EngineCodeMapping mapping)
        {
            var retVal = mapping;

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ProgrammeId", mapping.ProgrammeId, DbType.Int32);
                    para.Add("@EngineId", mapping.EngineId, DbType.Int32);
                    para.Add("@ExternalEngineCode", 
                        string.IsNullOrEmpty(mapping.ExternalEngineCode) ? null : mapping.ExternalEngineCode, DbType.String);
                    para.Add("@MappingId", null, DbType.Int32, ParameterDirection.Output);

                    conn.Execute("dbo.Fdp_EngineCode_Save", para, commandType: CommandType.StoredProcedure);

                    if (!mapping.MappingId.HasValue)
                    {
                        mapping.MappingId = para.Get<int>("@MappingId");
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

        public IEnumerable<Programme> ProgrammeGetMany()
        {
            IEnumerable<Programme> retVal = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    retVal = conn.Query<Programme>("dbo.OXO_Programme_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;   
        }

        public IEnumerable<Programme> ProgrammeByGatewayGetMany()
        {
            IEnumerable<Programme> retVal = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@TotalRecords", null, DbType.Int32, ParameterDirection.Output);

                    retVal = conn.Query<Programme>("dbo.Fdp_ProgrammeByGateway_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal; 
        }

        public Programme ProgrammeGet(int id)
        {
            Programme retVal = null;
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, DbType.Int32);
                    retVal = conn.Query<Programme>("dbo.OXO_Programme_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }

        public bool ProgrammeSave(Programme obj)
        {
            var retVal = true;
            var procName = (obj.IsNew ? "dbo.OXO_Programme_New" : "dbo.OXO_Programme_Edit");

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    obj.Save(CurrentCDSID);
 
                    var para = new DynamicParameters();

                   // para.Add("@p_AKA", obj.AKA, dbType: DbType.String, size: 500);
                    para.Add("@p_Notes", obj.Notes, DbType.String, size: 2000);
                    para.Add("@p_Product_Manager", obj.ProductManager, DbType.String, size: 8);
                    para.Add("@p_RSG_UID", obj.RSGUID, DbType.String, size: 500);
                    para.Add("@p_Active", obj.Active, DbType.Boolean);
                    para.Add("@p_Created_By", obj.CreatedBy, DbType.String, size: 8);
                    para.Add("@p_Created_On", obj.CreatedOn, DbType.DateTime);
                    para.Add("@p_Updated_By", obj.UpdatedBy, DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, DbType.DateTime);
                    para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

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

        public bool ProgrammeDelete(int id)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return true;
        }

        public Programme ProgrammeGetConfiguration(int id)
        {
            var retVal = new Programme();
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, DbType.Int32);
                    using (var multi = conn.QueryMultiple("dbo.OXO_Programme_GetConfiguration", para, commandType: CommandType.StoredProcedure))
                    {
                        retVal = multi.Read<Programme>().FirstOrDefault();
                        retVal.AllBodies = multi.Read<ModelBody>().ToList();
                        retVal.AllEngines = multi.Read<ModelEngine>().ToList();
                        retVal.AllTransmissions = multi.Read<ModelTransmission>().ToList();
                        retVal.AllTrims = multi.Read<ModelTrim>().ToList();
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

        public bool ProgrammeRemoveMarket(int progid, int marketid)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, DbType.Int32);
                    para.Add("@p_market_id", marketid, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_Market", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return true;
        }

        public bool ProgrammeAddFeature(int progid, int docid, int featid, int changesetid)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, DbType.Int32);
                    para.Add("@p_doc_id", docid, DbType.Int32);
                    para.Add("@p_feat_id", featid, DbType.Int32);
                    para.Add("@p_cdsid", CurrentCDSID, DbType.String, size:10);
                    para.Add("@p_changeset_id", changesetid, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Add_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return true;
        }

        public bool ProgrammeAddGSF(int progid, int docid, int featid, int changesetid)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, DbType.Int32);
                    para.Add("@p_doc_id", docid, DbType.Int32);
                    para.Add("@p_feat_id", featid, DbType.Int32);
                    para.Add("@p_cdsid", CurrentCDSID, DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Add_GSF", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return true;
        }

        public bool ProgrammeRemoveFeature(int progid, int docid, int featid, int changesetid)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, DbType.Int32);
                    para.Add("@p_doc_id", docid, DbType.Int32);
                    para.Add("@p_feat_id", featid, DbType.Int32);
                    para.Add("@p_cdsid", CurrentCDSID, DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }

            return true;
        }

        public bool ProgrammeRemoveGSF(int progid, int docid, int featid, int changesetid)
        {
            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, DbType.Int32);
                    para.Add("@p_doc_id", docid, DbType.Int32);
                    para.Add("@p_feat_id", featid, DbType.Int32);
                    para.Add("@p_cdsid", CurrentCDSID, DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_GSF", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                }
            }

            return true;
        }

    }
}