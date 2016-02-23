using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Reflection;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Extensions;
using log4net;

namespace FeatureDemandPlanning.DataStore
{
    public class FeatureDataStore : DataStoreBase
    {
        
        public FeatureDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<FdpFeature> FeatureGetManyByDocumentId(FeatureFilter filter)
        {
            var retVal = Enumerable.Empty<FdpFeature>();

            using (var conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@DocumentId", filter.DocumentId.Value, dbType: DbType.Int32);

                    retVal = conn.Query<FdpFeature>("Fdp_ProgrammeFeature_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
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
                    Log.Error(ex);
                    throw;
                }
            }

            return retVal;
        }
      
        public FdpFeatureMapping FeatureMappingDelete(FdpFeatureMapping featureMapping)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpFeatureMappingId", featureMapping.FdpFeatureMappingId, dbType: DbType.Int32);
                    
                    var results = conn.Query<FdpFeatureMapping>("Fdp_FeatureMapping_Delete", para, commandType: CommandType.StoredProcedure);
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
        public FdpFeatureMapping FeatureMappingGet(FdpFeatureMapping featureMapping)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureMappingId", featureMapping.FdpFeatureMappingId, dbType: DbType.Int32);

                    var results = conn.Query<FdpFeatureMapping>("Fdp_FeatureMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public FdpFeatureMapping FeatureMappingSave(FdpFeatureMapping featureMapping)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ImportFeatureCode", featureMapping.ImportFeatureCode, dbType: DbType.String);
                    para.Add("@ProgrammeId", featureMapping.ProgrammeId, dbType: DbType.Int32);
                    para.Add("@Gateway", featureMapping.Gateway, dbType: DbType.String);
                    para.Add("@FeatureId", featureMapping.FeatureId, dbType: DbType.Int32);
                    para.Add("@FeaturePackId", featureMapping.FeaturePackId, DbType.Int32);

                    var results = conn.Query<FdpFeatureMapping>("Fdp_FeatureMapping_Save", para, commandType: CommandType.StoredProcedure);
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
        public FdpFeature FdpFeatureDelete(FdpFeature featureToDelete)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@FdpFeatureId", featureToDelete.FdpFeatureId.GetValueOrDefault(), dbType: DbType.Int32);
                    
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpFeature FdpFeatureGet(FeatureFilter filter)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureId", filter.FeatureId.GetValueOrDefault(), dbType: DbType.Int32);
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public PagedResults<FdpFeature> FdpFeatureGetMany(FeatureFilter filter)
        {
            PagedResults<FdpFeature> retVal = null;

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

                    var results = conn.Query<FdpFeature>("dbo.Fdp_Feature_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpFeature>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpFeature>();

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
        public FdpFeature FdpFeatureSave(FdpFeature feature)
        {
            FdpFeature retVal = new EmptyFdpFeature();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = DynamicParameters.FromCDSId(CurrentCDSID);
                    para.Add("@ProgrammeId", feature.ProgrammeId.GetValueOrDefault(), dbType: DbType.Int32);
                    para.Add("@Gateway", feature.Gateway, dbType: DbType.String);
                    para.Add("@FeatureCode", feature.FeatureCode, dbType: DbType.String);
                    para.Add("@FeatureGroupId", feature.FeatureGroupId, dbType: DbType.Int32);
                    para.Add("@FeatureDescription", feature.BrandDescription, dbType: DbType.String);
                    
                    retVal = conn.Query<FdpFeature>("dbo.Fdp_Feature_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeatureMapping_Delete", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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
                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeatureMapping_Get", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeatureMapping_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
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

                    retVal = conn.Query<FdpSpecialFeature>("dbo.Fdp_SpecialFeatureMapping_Save", para, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        public FdpFeatureMapping FdpFeatureMappingDelete(FdpFeatureMapping featureMappingToDelete)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureMappingId", featureMappingToDelete.FdpFeatureMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpFeatureMapping>("Fdp_FeatureMapping_Delete", para, commandType: CommandType.StoredProcedure);
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
        public FdpFeatureMapping FdpFeatureMappingGet(FeatureMappingFilter filter)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpFeatureMappingId", filter.FeatureMappingId.GetValueOrDefault(), dbType: DbType.Int32);

                    var results = conn.Query<FdpFeatureMapping>("Fdp_FeatureMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public PagedResults<FdpFeatureMapping> FdpFeatureMappingGetMany(FeatureMappingFilter filter)
        {
            PagedResults<FdpFeatureMapping> retVal = null;

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
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpFeatureMapping>("dbo.Fdp_FeatureMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpFeatureMapping>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpFeatureMapping>();

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
        public FdpFeatureMapping FdpFeatureMappingCopy(FdpFeatureMapping featureMappingToCopy, IEnumerable<string> gateways)
        {
            FdpFeatureMapping retVal = new EmptyFdpFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpFeatureMappingId", featureMappingToCopy.FdpFeatureMappingId, DbType.Int32);
                    para.Add("@Gateways", gateways.ToCommaSeperatedList(), DbType.String);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var rows = conn.Execute("Fdp_FeatureMapping_Copy", para, commandType: CommandType.StoredProcedure);

                    retVal = FdpFeatureMappingGet(new FeatureMappingFilter() { FeatureMappingId = featureMappingToCopy.FdpFeatureMappingId });
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }
        public FdpSpecialFeatureMapping FdpSpecialFeatureMappingGet(SpecialFeatureMappingFilter filter)
        {
            FdpSpecialFeatureMapping retVal = new EmptyFdpSpecialFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpSpecialFeatureMappingId", filter.SpecialFeatureMappingId.GetValueOrDefault(), dbType: DbType.Int32);

                    var results = conn.Query<FdpSpecialFeatureMapping>("Fdp_SpecialFeatureMapping_Get", para, commandType: CommandType.StoredProcedure);
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
        public FdpSpecialFeatureMapping FdpSpecialFeatureMappingDelete(FdpSpecialFeatureMapping featureMappingToDelete)
        {
            FdpSpecialFeatureMapping retVal = new EmptyFdpSpecialFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@FdpSpecialFeatureMappingId", featureMappingToDelete.FdpSpecialFeatureMappingId, dbType: DbType.Int32);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var results = conn.Query<FdpSpecialFeatureMapping>("Fdp_SpecialFeatureMapping_Delete", para, commandType: CommandType.StoredProcedure);
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
        public PagedResults<FdpSpecialFeatureMapping> FdpSpecialFeatureMappingGetMany(SpecialFeatureMappingFilter filter)
        {
            PagedResults<FdpSpecialFeatureMapping> retVal = null;

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
                    para.Add("@TotalPages", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    para.Add("@TotalDisplayRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var results = conn.Query<FdpSpecialFeatureMapping>("dbo.Fdp_SpecialFeatureMapping_GetMany", para, commandType: CommandType.StoredProcedure);

                    if (results.Any())
                    {
                        totalRecords = para.Get<int>("@TotalRecords");
                        totalDisplayRecords = para.Get<int>("@TotalDisplayRecords");
                    }
                    retVal = new PagedResults<FdpSpecialFeatureMapping>()
                    {
                        PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                        TotalRecords = totalRecords,
                        TotalDisplayRecords = totalDisplayRecords,
                        PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : totalRecords
                    };

                    var currentPage = new List<FdpSpecialFeatureMapping>();

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

        public FdpSpecialFeatureMapping FdpSpecialFeatureMappingCopy(FdpSpecialFeatureMapping featureMappingToCopy, IEnumerable<string> gateways)
        {
            FdpSpecialFeatureMapping retVal = new EmptyFdpSpecialFeatureMapping();
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();

                    para.Add("@FdpSpecialFeatureMappingId", featureMappingToCopy.FdpSpecialFeatureMappingId, DbType.Int32);
                    para.Add("@Gateways", gateways.ToCommaSeperatedList(), DbType.String);
                    para.Add("@CDSId", CurrentCDSID, dbType: DbType.String);

                    var rows = conn.Execute("Fdp_SpecialFeatureMapping_Copy", para, commandType: CommandType.StoredProcedure);

                    retVal = FdpSpecialFeatureMappingGet(new SpecialFeatureMappingFilter() { SpecialFeatureMappingId = featureMappingToCopy.FdpSpecialFeatureMappingId });
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return retVal;
        }

        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}