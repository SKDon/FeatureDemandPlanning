using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;

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
        public FeatureMapping FeatureMappingDelete(FeatureMapping featureMapping)
        {
            FeatureMapping retVal = new EmptyFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpFeatureMappingId", featureMapping.FdpFeatureMappingId, dbType: DbType.Int32);
                    
                    var results = conn.Query<FeatureMapping>("Fdp_FeatureMapping_Delete", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureMappingDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FeatureMapping FeatureMappingGet(FeatureMapping featureMapping)
        {
            FeatureMapping retVal = new EmptyFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureMappingId", featureMapping.FdpFeatureMappingId, dbType: DbType.Int32);

                    var results = conn.Query<FeatureMapping>("Fdp_FeatureMapping_Get", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureMappingGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FeatureMapping FeatureMappingSave(FeatureMapping featureMapping)
        {
            FeatureMapping retVal = new EmptyFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ImportFeatureCode", featureMapping.ImportFeatureCode, dbType: DbType.String);
                    para.Add("@ProgrammeId", featureMapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", featureMapping.Gateway, dbType: DbType.String);
                    para.Add("@FeatureId", featureMapping.FeatureId, dbType: DbType.Int32);
                    
                    var results = conn.Query<FeatureMapping>("Fdp_FeatureMapping_Save", para, commandType: CommandType.StoredProcedure);
                    if (results.Any())
                    {
                        retVal = results.First();
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FeatureMappingSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpFeature FdpFeatureDelete(int fdpFeatureId)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpFeatureId", fdpFeatureId, dbType: DbType.Int32);
                    
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpFeatureDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpFeature FdpFeatureGet(int fdpFeatureId)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureId", fdpFeatureId, dbType: DbType.Int32);
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpFeatureGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<FdpFeature> FdpFeatureGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpFeature> retVal = Enumerable.Empty<FdpFeature>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", filter.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", filter.Gateway, dbType: DbType.String);
    
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpFeatureGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpFeature FdpFeatureSave(FdpFeature feature)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FeatureCode", feature.FeatureCode, dbType: DbType.String);
                    para.Add("@FeatureGroupId", feature.FeatureGroupId, dbType: DbType.Int32);
                    para.Add("@FeatureDescription", feature.BrandDescription, dbType: DbType.String);
                    para.Add("@ProgrammeId", feature.ProgrammeId.GetValueOrDefault(), dbType: DbType.Int32);
                    para.Add("@Gateway", feature.Gateway, dbType: DbType.String);
                    
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpFeatureSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpSpecialFeature FdpSpecialFeatureDelete(int fdpFeatureId)
        {
            FdpSpecialFeature retVal = new EmptyFdpSpecialFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpSpecialFeatureId", fdpFeatureId, dbType: DbType.Int32);

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeature_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpSpecialFeatureDelete", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpSpecialFeature FdpSpecialFeatureGet(int fdpFeatureId)
        {
            FdpSpecialFeature retVal = new EmptyFdpSpecialFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpSpecialFeatureId", fdpFeatureId, dbType: DbType.Int32);
                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeature_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpSpecialFeatureGet", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public IEnumerable<FdpSpecialFeature> FdpSpecialFeatureGetMany(ProgrammeFilter filter)
        {
            IEnumerable<FdpSpecialFeature> retVal = Enumerable.Empty<FdpSpecialFeature>();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", filter.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", filter.Gateway, dbType: DbType.String);

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeature_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpSpecialFeatureGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
        public FdpSpecialFeature FdpSpecialFeatureSave(FdpSpecialFeature specialFeature)
        {
            FdpSpecialFeature retVal = new EmptyFdpSpecialFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FeatureCode", specialFeature.FeatureCode, dbType: DbType.String);
                    para.Add("@FdpSpecialFeatureTypeId", specialFeature.SpecialFeatureType.FdpSpecialFeatureTypeId, dbType: DbType.Int32);
                    para.Add("@ProgrammeId", specialFeature.ProgrammeId.GetValueOrDefault(), dbType: DbType.Int32);
                    para.Add("@Gateway", specialFeature.Gateway, dbType: DbType.String);

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeature_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FeatureDataStore.FdpSpecialFeatureSave", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }
}