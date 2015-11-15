using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class TakeRateFilter : ProgrammeFilter
    {
        public int? TakeRateId { get; set; }
        public int? TakeRateStatusId { get; set; }
    }
}
