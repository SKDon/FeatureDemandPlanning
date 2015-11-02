using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Model.ViewModel
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