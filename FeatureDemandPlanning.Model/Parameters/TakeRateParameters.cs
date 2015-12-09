using FeatureDemandPlanning.Model.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TakeRateParameters : JQueryDataTableParameters
    {
        public int? TakeRateId { get; set; }
        public int? TakeRateDataItemId { get; set; }
        public string FilterMessage { get; set; }
        public int? TakeRateStatusId { get; set; }
        public TakeRateAction Action { get; set; }

        public IList<DataChange> Changes { get; set; }

        public TakeRateParameters()
        {
            Action = TakeRateAction.NotSet;
            Changes = new List<DataChange>();
        }

        public string GetActionSpecificParameters()
        {
            throw new NotImplementedException();
        }
    }
}
