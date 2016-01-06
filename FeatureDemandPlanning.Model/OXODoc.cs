using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Xml;
using System.IO;
using System.Data.SqlClient;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model
{
    public enum OXOSection {MBM, FBM, FRS, FPS, PCK, GSF};

    public class OXODocComparer : IEqualityComparer<OXODoc>
    {
        public bool Equals(OXODoc x, OXODoc y)
        {
            if (x == null || y == null)
                return false;

            return x.Id == y.Id; 
        }

        public int GetHashCode(OXODoc obj)
        {
            return obj.Id.GetHashCode();
        }
    }

    [Serializable]
    public class OXODoc : BusinessObject
    {
        private IDataContext _dataContext = null;

        public int ProgrammeId { get; set; }
        public decimal VersionId { get; set; }
        public string Gateway { get; set; }
        public string NextGateway { get; set; }
        public string Status { get; set; }
        public string Owner { get; set; }
        public string VehicleName { get; set; }
        public string VehicleAKA { get; set; }
        public string ModelYear { get; set; }
        public string VehicleMake { get; set; }
        public string MBMCreated { get; set; }
        public string MBMUpdated { get; set; }
        public string FBMCreated { get; set; }
        public string FBMUpdated { get; set; }
        public string GSFCreated { get; set; }
        public string GSFUpdated { get; set; }
        public bool Editable { get; set; }
        public bool Archived { get; set; }
        public IEnumerable<ModelEngine> AllEngines { get; set; }
        public IEnumerable<ModelBody> AllBodies { get; set; }
        public IEnumerable<ModelTransmission> AllTransmissions { get; set; }
        public IEnumerable<ModelTrim> AllTrims { get; set; }

        public string Name 
        {
            get
            {
                string retVal = String.Empty;
                retVal = String.Format("{0} {1} {2} {3} {4} {5}", VehicleName, VehicleAKA, ModelYear, Gateway, VersionLabel, Status);
                return retVal;
            }
        }

        public string VersionLabel 
        {
            get
            {
                string retVal = String.Empty; ;
                retVal = String.Format("v{0:N1}", VersionId);
                return retVal;
            }
        }

        public int VersionMajor
        {
            get
            {
                int retVal = 0; ;
                retVal = Int32.Parse("" + VersionLabel.ElementAt(1));
                return retVal;
            }
        }

        public int VersionMinor
        {
            get
            {
                int retVal = 0; ;
                retVal = Int32.Parse("" + VersionLabel.ElementAt(3));
                return retVal;
            }
        }

        public new string CreatedOn
        {
            get
            {

                if (base.CreatedOn.HasValue)
                    return base.CreatedOn.Value.ToString("yyyy-MM-dd HH:mm");
                else
                    return "";
            }

        }

        public new string LastUpdated
        {
            get
            {

                if (base.LastUpdated.HasValue)
                    return base.LastUpdated.Value.ToString("yyyy-MM-dd HH:mm");
                else
                    return "";
            }
        }

        // A blank constructor
        public OXODoc() { ;}

        public OXODoc(IDataContext dataContext)
        {
            _dataContext = dataContext;
        }

        public int ValidateXCLDoc(string mode, int progid, int objectId, string cdsid)
        {
            return _dataContext.Document.ValidateXclDoc(Id, mode, progid, objectId);
        }

        private string LoadSourceXML(int docid, string mode, int progid, int objectid)
        {
            StringBuilder sb = new StringBuilder();            
            using (IDbConnection conn = _dataContext.GetHelper().GetDBConnection())
            {        
                try
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = (SqlConnection)conn;
                    cmd.CommandText = "EXEC dbo.OXO_Data_GetXML @p_doc_id = " + docid + ", @p_level = '" + mode + "', @p_prog_id = " + progid + ", @p_object_id = " + objectid;
                    XmlReader xmlr = cmd.ExecuteXmlReader();
                    xmlr.Read();
                    while (xmlr.ReadState != System.Xml.ReadState.EndOfFile)
                    {
                        sb.Append(xmlr.ReadOuterXml());
                    }
                    conn.Close();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODoc.LoadSourceXML", ex.Message, "system");
                }
            }
            return sb.ToString();                
        }

        private string LoadSourceXSL(int progid)
        {
            StringBuilder sb = new StringBuilder();
            using (IDbConnection conn = _dataContext.GetHelper().GetDBConnection())
            {
                try
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = (SqlConnection)conn;
                    cmd.CommandText = "EXEC dbo.OXO_Data_GetXSL @p_prog_id =" + progid;
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        sb.AppendLine(dr["XML"].ToString());
                    }
                    conn.Close();
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("OXODoc.LoadSourceXSL", ex.Message, "system");
                }
            }
            return sb.ToString();
        }

        private string LoadRuleSetsFile(string filename)
        {
            StringBuilder sb = new StringBuilder();
            using (StreamReader sr = new StreamReader(filename))
            {
                sb.Append(sr.ReadToEnd());
            }
            return sb.ToString();
        }

        public bool Export(string cdsid, string comment,string PACN)
        {
            bool retVal = false;
            try
            {
                retVal = _dataContext.Document.Export(this, comment, PACN);
            }
            catch (Exception ex)
            {
                AppHelper.LogError("MarketDataStore.MarketGetMany", ex.Message, cdsid);
                retVal = false;        
            }

            return retVal;
        }

        public void GetDocConfiguration()
        {
            _dataContext.Document.GetConfiguration(this);
        }
    }


    public class OXODataItem : BusinessObject
    {
        public string Section { get; set; }
        public int ModelId { get; set; }
        public int MarketId { get; set; }
        public int MarketGroupId { get; set; }
        public int FeatureId { get; set; }
        public int PackId { get; set; }
        public string Code { get; set; }
        public string Reminder { get; set; }
    }

    public class OXODataItemHistory : BusinessObject
    {
        private string _updatedBy;

        public int SetId { get; set; }
        public decimal VersionId { get; set; }
        public int ItemId { get; set; }
        public string ItemCode { get; set; }
        public string Reminder { get; set; }

        public string VersionLabel
        {
            get {
                return String.Format("v{0:N1}", VersionId);
            }
        
        }

        public new  string UpdatedBy
        {
            get { return _updatedBy; }
            set { _updatedBy = value; }
        }

        public new string LastUpdated
        {
            get
            {

                if (base.LastUpdated.HasValue)
                    return base.LastUpdated.Value.ToString("yyyy-MM-dd HH:mm");
                else
                    return "";
            }
        }

        public OXODataItemHistory() { ;}
    }

    public class OXODataChain : BusinessObject
    {
        public string Level { get; set; }
        public string LevelName { get; set; }        
        public int ModelId { get; set; }
        public string ModelName { get; set; }
        public int FeatureId { get; set; }
        public string FeatureName { get; set; }
        public string OXOCode { get; set; }
    }

    public class ModelFilter
    {
        public int DocumentId;
        public int ProgrammeId;
        public string Mode;
        public int ObjectId;
        public int[] BodyIds;
        public int[] EngineIds;
        public int[] TranIds;
        public int[] TrimIds;
        public int[] ModelIds;

    }

    /// <summary>
    /// Allows the comparison of documents to determine unique gateways
    /// </summary>
    public class UniqueGateway : IEqualityComparer<OXODoc>
    {
        public bool Equals(OXODoc x, OXODoc y)
        {
            return x.Gateway.Equals(y.Gateway, StringComparison.InvariantCultureIgnoreCase);
        }

        public int GetHashCode(OXODoc obj)
        {
            return obj.GetHashCode();
        }
    }

}