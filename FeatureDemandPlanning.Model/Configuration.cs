using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model
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
