using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class FdpModel : Model
    {
        public int? FdpDerivativeId { get; set; }
        public int? FdpModelId { get; set; }
        public int? FdpTrimId { get; set; }

        public string Identifier
        {
            get
            {
                if (FdpModelId.HasValue)
                {
                    return string.Format("F{0}", FdpModelId);
                }
                else
                {
                    return string.Format("O{0}", Id);
                }
            }
        }
    }
}
