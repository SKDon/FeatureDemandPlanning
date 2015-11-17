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
        
        public EngineCodeMappingViewModel() : base()
        {
        }

        public static EngineCodeMappingViewModel GetModel(IDataContext context)
        {
            return new EngineCodeMappingViewModel()
            {
                Configuration = context.ConfigurationSettings
            };
        }
    }
}