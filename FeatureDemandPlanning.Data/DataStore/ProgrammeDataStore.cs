using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FeatureDemandPlanning.BusinessObjects;
using System.Data;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Dapper;

namespace FeatureDemandPlanning.DataStore
{
    public class ProgrammeDataStore : DataStoreBase
    {

        public ProgrammeDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public static void PopulateConfiguration(Programme programme)
        {
            ProgrammeDataStore ds = new ProgrammeDataStore("system");
            Programme obj = ds.ProgrammeGetConfiguration(programme.Id);
            if (obj != null)
            {
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
        }

        public IEnumerable<EngineCodeMapping> EngineCodeMappingGetMany()
        {
            IList<EngineCodeMapping> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@TotalRecords", null, dbType: DbType.Int32, direction: ParameterDirection.Output);

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
                    AppHelper.LogError("ProgrammeDS.EngineCodeMappingGetMany", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }

            return retVal;
        }

        public EngineCodeMapping EngineCodeMappingSave(EngineCodeMapping mapping)
        {
            var retVal = mapping;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@ProgrammeId", mapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@EngineId", mapping.EngineId, dbType: DbType.Int32);
                    para.Add("@ExternalEngineCode", 
                        string.IsNullOrEmpty(mapping.ExternalEngineCode) ? null : mapping.ExternalEngineCode, dbType: DbType.String);
                    para.Add("@MappingId", null, dbType: DbType.Int32, direction: ParameterDirection.Output);

                    conn.Execute("dbo.Fdp_EngineCode_Save", para, commandType: CommandType.StoredProcedure);

                    if (!mapping.MappingId.HasValue)
                    {
                        mapping.MappingId = para.Get<int>("@MappingId");
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.EngineCodeMappingSave", ex.Message, CurrentCDSID);
                    throw new ApplicationException(ex.Message);
                }
            }

            return mapping;
        }

        public IEnumerable<Programme> ProgrammeGetMany()
        {
            IEnumerable<Programme> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    retVal = conn.Query<Programme>("dbo.OXO_Programme_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;   
        }

        public IEnumerable<Programme> ProgrammeByGatewayGetMany()
        {
            IEnumerable<Programme> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@TotalRecords", null, dbType: DbType.Int32, direction: ParameterDirection.Output);

                    retVal = conn.Query<Programme>("dbo.Fdp_ProgrammeByGateway_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeByGatewayGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal; 
        }

        public Programme ProgrammeGet(int id)
        {
            Programme retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<Programme>("dbo.OXO_Programme_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public bool ProgrammeSave(Programme obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_Programme_New" : "dbo.OXO_Programme_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    obj.Save(this.CurrentCDSID);
 
                    var para = new DynamicParameters();

                   // para.Add("@p_AKA", obj.AKA, dbType: DbType.String, size: 500);
                    para.Add("@p_Notes", obj.Notes, dbType: DbType.String, size: 2000);
                    para.Add("@p_Product_Manager", obj.ProductManager, dbType: DbType.String, size: 8);
                    para.Add("@p_RSG_UID", obj.RSGUID, dbType: DbType.String, size: 500);
                    para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
                    para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
                    para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
                    para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
                    para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

                    conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

                    if (obj.Id == 0)
                    {
                        obj.Id = para.Get<int>("@p_Id");
                    }

                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
            
        }

        public bool ProgrammeDelete(int id)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public Programme ProgrammeGetConfiguration(int id)
        {
            Programme retVal = new Programme();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
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
                    AppHelper.LogError("ProgrammeDS.ProgrammeGetConfiguration", ex.Message, CurrentCDSID);
                    retVal = null;
                }
            }

            return retVal;
        }

        public bool ProgrammeRemoveMarket(int progid, int marketid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_market_id", marketid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_Market", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeRemoveMarket", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool ProgrammeAddFeature(int progid, int docid, int featid, int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid", this.CurrentCDSID, dbType: DbType.String, size:10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Add_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeAddFeature", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool ProgrammeAddGSF(int progid, int docid, int featid, int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid", this.CurrentCDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Add_GSF", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeAddGSF", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool ProgrammeRemoveFeature(int progid, int docid, int featid, int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid", this.CurrentCDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeRemoveFeature", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool ProgrammeRemoveGSF(int progid, int docid, int featid, int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid", this.CurrentCDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_GSF", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("ProgrammeDS.ProgrammeRemoveGSF", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

    }
}