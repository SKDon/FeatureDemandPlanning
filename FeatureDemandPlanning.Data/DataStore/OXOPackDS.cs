using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    [Serializable]
    public class PackDataStore : DataStoreBase
    {
        public PackDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<PackFeature> PackFeatureGetMany(int progId)
        {
            IEnumerable<PackFeature> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_programme_id", progId, dbType: DbType.Int32);
                    retVal = conn.Query<PackFeature>("dbo.OXO_PackFeature_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.FeaturePackGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public IEnumerable<PackFeature> PackFeatureGetManyBlank(int progId)
        {
            IEnumerable<PackFeature> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_programme_id", progId, dbType: DbType.Int32);
                    retVal = conn.Query<PackFeature>("dbo.OXO_PackFeature_GetManyBlank", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.FeaturePackGetManyBlank", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public Pack PackGet(int id, int docid, bool deepGet = false)
        {
            Pack retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    para.Add("@p_doc_Id", docid, dbType: DbType.Int32);
                    para.Add("@p_deep", id, dbType: DbType.Int32);
                    retVal = conn.Query<Pack>("dbo.OXO_Pack_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.PackGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public bool PackSave(Pack obj)
        {
            bool retVal = true;
            string procName = (obj.IsNew ? "dbo.OXO_Pack_New" : "dbo.OXO_Pack_Edit");

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    obj.Save(this.CurrentCDSID);

                    var para = new DynamicParameters();

                    para.Add("@p_Doc_Id", obj.DocId, dbType: DbType.Int32);
                    para.Add("@p_Programme_Id", obj.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@p_Name", obj.Name, dbType: DbType.String, size: 500);
                    para.Add("@p_extra_info", obj.ExtraInfo, dbType: DbType.String, size: 500);
                    para.Add("@p_feature_Code", obj.FeatureCode, dbType: DbType.String, size: 50);
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
                    AppHelper.LogError("PackDataStore.PackSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;

        }

        public bool PackDelete(int id)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Pack_Delete", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.PackDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool PackDelete(int progid, int docid, int packid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_pack_id", packid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Programme_Remove_Pack", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.PackDelete", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool PackAddFeature(int progid,int docid, int packid, int featid,int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_pack_id", packid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid",  CurrentCDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Pack_Add_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.PackAddFeature", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public bool PackRemoveFeature(int progid, int docid, int packid, int featid, int changesetid)
        {
            bool retVal = true;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_pack_id", packid, dbType: DbType.Int32);
                    para.Add("@p_feat_id", featid, dbType: DbType.Int32);
                    para.Add("@p_cdsid", CurrentCDSID, dbType: DbType.String, size: 10);
                    para.Add("@p_changeset_id", changesetid, dbType: DbType.Int32);
                    conn.Execute("dbo.OXO_Pack_Remove_Feature", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.PackRemoveFeature", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }

            return retVal;
        }

        public IEnumerable<Pack> ProgrammePackGetMany(int progId, int docId, bool newOnly)
        {
            IEnumerable<Pack> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int32);
                    para.Add("@p_new_only", newOnly, dbType: DbType.Boolean);
                    retVal = conn.Query<Pack>("dbo.OXO_ProgrammePackGetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("PackDataStore.ProgrammePackGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }
    }

}