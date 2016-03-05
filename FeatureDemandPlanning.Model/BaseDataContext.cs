using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.Model
{
    public class BaseDataContext
    {
        public string CDSID { get; set; }

        public BaseDataContext(string cdsId)
        {
            CDSID = cdsId;
        }

        protected static readonly Logger Log = Logger.Instance;
    }
}
