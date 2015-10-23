using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class FeatureDataStore : DataStoreBase
    {
        
        public FeatureDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<Feature> FeatureGetMany(string mode = "generic", int paramId = 0, int docid = 0, string lookup = null, string group = null, int excludeObjId = 0, int excludeDocId = 0, bool useOACode = false)
        {
            IEnumerable<Feature> retVal = new List<Feature>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    string sp_name = "";
                    switch (mode)
                    {
                        case "generic":
                            sp_name = "dbo.OXO_GenericFeature_GetMany";
                            break;
                        case "vehicle":
                            sp_name = "dbo.OXO_VehicleFeature_GetMany";
                            para.Add("@p_vehicle_id", paramId, dbType: DbType.Int32);
                            para.Add("@p_group", group, dbType: DbType.String, size: 500);
                            para.Add("@p_exclude_progid", excludeObjId, dbType: DbType.Int32);
                            para.Add("@p_exclude_docid", excludeDocId, dbType: DbType.Int32);
                            para.Add("@p_use_OA_code", useOACode, dbType: DbType.Boolean);
                            break;
                        case "programme":
                            sp_name = "dbo.OXO_ProgrammeFeature_GetMany";
                            para.Add("@p_prog_id", paramId, dbType: DbType.Int32);
                            para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                            para.Add("@p_group", group, dbType: DbType.String, size: 500);
                            para.Add("@p_exclude_packid", excludeObjId, dbType: DbType.Int32);
                            break;
                        case "gsf":
                            sp_name = "dbo.OXO_Vehicle_GSF_GetMany";
                            para.Add("@p_vehicle_id", paramId, dbType: DbType.Int32);
                            para.Add("@p_group", group, dbType: DbType.String, size: 500);
                            para.Add("@p_exclude_progid", excludeObjId, dbType: DbType.Int32);
                            para.Add("@p_exclude_docid", excludeDocId, dbType: DbType.Int32);
                            para.Add("@p_use_OA_code", useOACode, dbType: DbType.Boolean);
                            break;
                        case "fdp":
                            sp_name = "dbo.OXO_Feature_GetMany";
                            para.Add("@p_vehicle_id", paramId, dbType: DbType.Int32);
                            lookup = "@@@";
                            break;
                    }

                    para.Add("@p_lookup", lookup, dbType: DbType.String, size: 50);
                    retVal = conn.Query<Feature>(sp_name, para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public IEnumerable<Feature> FeatureGetManyBlank()
        {
            IEnumerable<Feature> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    retVal = conn.Query<Feature>("dbo.OXO_Feature_GetManyBlank", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureGetManyBlank", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        // TODO: Need checking
        public Feature FeatureGet(int id)
        {
            Feature retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                    retVal = conn.Query<Feature>("dbo.OXO_Feature_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public Feature ProgrammeFeatureGet(int progid, int docid, int featureid)
        {
            Feature retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feature_id", featureid, dbType: DbType.Int32);
                    retVal = conn.Query<Feature>("dbo.OXO_ProgrammeFeature_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeFeatureGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public Feature ProgrammeGSFGet(int progid, int docid, int featureid)
        {
            Feature retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progid, dbType: DbType.Int32);
                    para.Add("@p_doc_id", docid, dbType: DbType.Int32);
                    para.Add("@p_feature_id", featureid, dbType: DbType.Int32);
                    retVal = conn.Query<Feature>("dbo.OXO_ProgrammeGSF_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeGSFGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        // TODO:
        // Need to disable this for now, until the feature maintenance come back to play
        //
        //public bool FeatureSave(Feature obj)
        //{
        //    bool retVal = true;
        //    string procName = (obj.IsNew ? "dbo.OXO_Feature_New" : "dbo.OXO_Feature_Edit");
        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {

        //            obj.Save(this.CurrentCDSID);

        //            var para = new DynamicParameters();

        //            para.Add("@p_Description", obj.BrandDescription, dbType: DbType.String, size: 500);
        //            para.Add("@p_Notes", obj.Notes, dbType: DbType.String, size: 2000);
        //            para.Add("@p_PROFET", obj.FeatureCode, dbType: DbType.String, size: 500);
        //            para.Add("@p_Active", obj.Active, dbType: DbType.Boolean);
        //            para.Add("@p_Feature_Group", obj.FeatureGroup, dbType: DbType.String, size: 500);
        //            para.Add("@p_Created_By", obj.CreatedBy, dbType: DbType.String, size: 8);
        //            para.Add("@p_Created_On", obj.CreatedOn, dbType: DbType.DateTime);
        //            para.Add("@p_Updated_By", obj.UpdatedBy, dbType: DbType.String, size: 8);
        //            para.Add("@p_Last_Updated", obj.LastUpdated, dbType: DbType.DateTime);
        //            para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

        //            conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

        //            if (obj.Id == 0)
        //            {
        //                obj.Id = para.Get<int>("@p_Id");
        //            }

        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("FeatureDataStore.FeatureGet", ex.Message, CurrentCDSID);
        //            retVal = false;
        //        }
        //    }
        //    return retVal;
        //}

        //public bool FeatureDelete(int id)
        //{
        //    bool retVal = true;
        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {
        //            var para = new DynamicParameters();
        //            para.Add("@p_Id", id, dbType: DbType.Int32);
        //            conn.Execute("dbo.OXO_Feature_Delete", para, commandType: CommandType.StoredProcedure);
        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("FeatureDataStore.FeatureDelete", ex.Message, CurrentCDSID);
        //            retVal = false;
        //        }
        //    }

        //    return retVal;
        //}

        //public bool ProgrammeFeatureAdd(int progId, string fGroup, string fDescr, string fNote, out int featId)
        //{
        //    bool retVal = true;
        //    featId = 0;
        //    string procName = "dbo.OXO_Programme_Feature_New";
        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {
   
        //            var para = new DynamicParameters();

        //            para.Add("@p_prog_id", progId, dbType: DbType.Int32);
        //            para.Add("@p_Description", fDescr, dbType: DbType.String, size: 500);
        //            para.Add("@p_Notes", fNote, dbType: DbType.String, size: 2000);
        //            para.Add("@p_Feature_Group", fGroup, dbType: DbType.String, size: 500);
        //            para.Add("@p_Created_By", CurrentCDSID, dbType: DbType.String, size: 8);
        //            para.Add("@p_Created_On", DateTime.Now, dbType: DbType.DateTime);
        //            para.Add("@p_Updated_By", CurrentCDSID, dbType: DbType.String, size: 8);
        //            para.Add("@p_Last_Updated", DateTime.Now, dbType: DbType.DateTime);
        //            para.Add("@p_Id", dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

        //            conn.Execute(procName, para, commandType: CommandType.StoredProcedure);

        //            featId = para.Get<int>("@p_Id"); ;
        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("FeatureDataStore.ProgrammeFeatureAdd", ex.Message, CurrentCDSID);
        //            retVal = false;
        //        }
        //    }
        //    return retVal;
        //}

        //public IEnumerable<RuleTooltip> RuleToolTipGetByFeature(int progId, int featureId)
        //{
        //    IEnumerable<RuleTooltip> retVal = new List<RuleTooltip>();
        //    using (IDbConnection conn = DbHelper.GetDBConnection())
        //    {
        //        try
        //        {
        //            var para = new DynamicParameters();
        //            para.Add("@p_prog_id", progId, dbType: DbType.Int16) ;
        //            para.Add("@p_feature_id", featureId, dbType: DbType.Int16);
        //            retVal = conn.Query<RuleTooltip>("dbo.OXO_Rule_GetManyByFeature", para, commandType: CommandType.StoredProcedure);
        //        }
        //        catch (Exception ex)
        //        {
        //            AppHelper.LogError("FeatureDataStore.RuleToolTipGetByFeature", ex.Message, CurrentCDSID);
        //        }
        //    }

        //    return retVal;   
        //}

        public string RuleToolTipGetByFeature(int progId, int docId, int featureId)
        {
            string retVal = String.Empty;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_prog_id", progId, dbType: DbType.Int16);
                    para.Add("@p_doc_id", docId, dbType: DbType.Int16);
                    para.Add("@p_feature_id", featureId, dbType: DbType.Int16);
                    retVal = conn.Query<string>("dbo.OXO_Feature_GetRuleText", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.RuleToolTipGetByFeature", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public bool ProgrammeFeatureCommentSave(int progid, int docid, int featureid, string comment)
        {
            bool retVal = true;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    string thisComment = string.Empty;
                    
                    if(!string.IsNullOrEmpty(comment))
                        thisComment = comment.Trim();
                    var para = new DynamicParameters();
                    para.Add("@p_progid", progid, dbType: DbType.Int32);
                    para.Add("@p_docid", docid, dbType: DbType.Int32);
                    para.Add("@p_featureid", featureid, dbType: DbType.Int32);
                    para.Add("@p_comment", thisComment, dbType: DbType.String, size: 2000);
                    para.Add("@p_CDSID", CurrentCDSID, dbType: DbType.String, size: 10);
                    conn.Execute("dbo.OXO_ProgrammeFeatureComment_Save", para, commandType: CommandType.StoredProcedure);                
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeFeatureCommentSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }
            return retVal;            
        }

        public bool ProgrammeFeatureRuleTextSave(int progid, int docid, int featureid, string ruleText)
        {
            bool retVal = true;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    string thisRuleText = string.Empty;

                    if (!string.IsNullOrEmpty(ruleText))
                        thisRuleText = ruleText.Trim();
                    var para = new DynamicParameters();
                    para.Add("@p_progid", progid, dbType: DbType.Int32);
                    para.Add("@p_docid", docid, dbType: DbType.Int32);
                    para.Add("@p_featureid", featureid, dbType: DbType.Int32);
                    para.Add("@p_ruletext", thisRuleText, dbType: DbType.String, size: 2000);
                    para.Add("@p_CDSID", CurrentCDSID, dbType: DbType.String, size: 10);
                    conn.Execute("dbo.OXO_ProgrammeFeatureRuleText_Save", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeFeatureCommentSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }
            return retVal;
        }

        public bool ProgrammeGSFCommentSave(int progid, int docid, int featureid, string comment)
        {
            bool retVal = true;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    string thisComment = string.Empty;

                    if (!string.IsNullOrEmpty(comment))
                        thisComment = comment.Trim();
                    var para = new DynamicParameters();
                    para.Add("@p_progid", progid, dbType: DbType.Int32);
                    para.Add("@p_docid", docid, dbType: DbType.Int32);
                    para.Add("@p_featureid", featureid, dbType: DbType.Int32);
                    para.Add("@p_comment", thisComment, dbType: DbType.String, size: 2000);
                    para.Add("@p_CDSID", CurrentCDSID, dbType: DbType.String, size: 10);
                    conn.Execute("dbo.OXO_ProgrammeGSFComment_Save", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeGSFCommentSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }
            return retVal;
        }

        public bool ProgrammeGSFRuleTextSave(int progid, int docid, int featureid, string comment)
        {
            bool retVal = true;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    string thisComment = string.Empty;

                    if (!string.IsNullOrEmpty(comment))
                        thisComment = comment.Trim();
                    var para = new DynamicParameters();
                    para.Add("@p_progid", progid, dbType: DbType.Int32);
                    para.Add("@p_docid", docid, dbType: DbType.Int32);
                    para.Add("@p_featureid", featureid, dbType: DbType.Int32);
                    para.Add("@p_ruletext", thisComment, dbType: DbType.String, size: 2000);
                    para.Add("@p_CDSID", CurrentCDSID, dbType: DbType.String, size: 10);
                    conn.Execute("dbo.OXO_ProgrammeGSFRuleText_Save", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.ProgrammeGSFCommentSave", ex.Message, CurrentCDSID);
                    retVal = false;
                }
            }
            return retVal;
        }
       
        public IEnumerable<MFD> MFDFeatureGetMany(int section)
        {
            IEnumerable<MFD> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_section", section, dbType: DbType.Int32);
                    retVal = conn.Query<MFD>("dbo.OXO_MFD_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.MFDFeatureGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public IEnumerable<JMFD> JMFDFeatureGetMany(string vehName,string groupName)
        {
            IEnumerable<JMFD> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_vehicle", vehName, dbType: DbType.String, size:50);
                    para.Add("@p_group", groupName, dbType: DbType.String, size: 100);
                    retVal = conn.Query<JMFD>("dbo.OXO_JMFD_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.JMFDFeatureGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public IEnumerable<FeatureGroup> FeatureGroupGetMany(bool all = false)
        {
            IEnumerable<FeatureGroup> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_all", all, dbType: DbType.Boolean);
                    retVal = conn.Query<FeatureGroup>("dbo.OXO_FeatureGroup_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureGroupGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

    }
}