using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model
{
    public class BaseDataContext
    {
        public string CDSID { get; set; }

        public BaseDataContext(string cdsId)
        {
            CDSID = cdsId;
        }
    }
}
