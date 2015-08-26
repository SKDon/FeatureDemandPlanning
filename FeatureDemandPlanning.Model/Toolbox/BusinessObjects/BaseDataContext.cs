using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
