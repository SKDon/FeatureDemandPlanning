using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class EngineCodeMappingViewModel : SharedModelBase
    {
        public PagedResults<EngineCodeMapping> EngineCodeMappings { get; set; }
        public dynamic Configuration { get; set; }

        public EngineCodeMappingViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
        }
    }
}