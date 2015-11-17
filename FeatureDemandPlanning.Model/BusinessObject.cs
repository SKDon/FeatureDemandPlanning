using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Model
{
    [Serializable]
    public class BusinessObject
    {
        public int Id { get; set; }
        public int ParentId { get; set; }
        public int DisplayOrder { get; set; }
        public bool Active { get; set; }
        [ScriptIgnore]
        public string CreatedBy { get; set; }
        [ScriptIgnore]
        public DateTime? CreatedOn { get; set; }
        [ScriptIgnore]
        public string UpdatedBy { get; set; }
        [ScriptIgnore]
        public DateTime? LastUpdated { get; set; }

        public string JsonString()
        {
            var json = new JavaScriptSerializer().Serialize(this);
            return json;
        }

        public bool  IsNew
        {
            get
            {
                return (Id > 0 ? false : true);
            }
        }

        public void Save(string cdsid)
        {
            if (this.IsNew)
            {
                this.CreatedBy = cdsid;
                this.CreatedOn = DateTime.Now;
            }

            this.UpdatedBy = cdsid;
            this.LastUpdated = DateTime.Now;

        }

    }

    public class DataStoreBase
    {
        public string CurrentCDSID { get; set; }

        public DataStoreBase()
        {
        }
        public DataStoreBase(string cdsId)
        {
            CurrentCDSID = cdsId;
        }
    }

    [Serializable]
    public class NameValuePair
    {
        public string name { get; set; }
        public string value { get; set; }
    }
}