using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Runtime.Serialization;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ConfigurationModel
    {
        public dynamic Configuration { get { return _dataContext.Configuration; } }

        public ConfigurationModel(IDataContext dataContext)
        {
            _dataContext = dataContext;
        }

        private IDataContext _dataContext = null;
    }
}