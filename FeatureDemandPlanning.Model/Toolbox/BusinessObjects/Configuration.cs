using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Configuration
    {
        private dynamic _settings = null;

        public Configuration(IDataContext dataContext)
        {
            HydrateConfigurationFromData(dataContext);
        }

        private void HydrateConfigurationFromData(IDataContext dataContext)
        {
            _settings = dataContext.Configuration.Configuration;
        }
    }
}
