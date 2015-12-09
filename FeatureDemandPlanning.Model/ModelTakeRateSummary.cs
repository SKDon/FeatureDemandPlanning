using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class ModelTakeRateSummary
    {
        public string StringIdentifier { get; set; }
        public bool IsFdpModel { get; set; }
        public int? ModelId
        {
            get
            {
                if (IsFdpModel)
                {
                    return null;
                }
                return int.Parse(StringIdentifier.Remove(0));
            }
        }
        public int? FdpModelId
        {
            get
            {
                if (!IsFdpModel)
                {
                    return null;
                }
                return int.Parse(StringIdentifier.Remove(0));
            }
        }
        public int Volume { get; set; }
        public decimal PercentageOfFilteredVolume { get; set; }
    }
}
