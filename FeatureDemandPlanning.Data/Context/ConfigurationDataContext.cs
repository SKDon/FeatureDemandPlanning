using System;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model;
using System.Collections.Generic;

namespace FeatureDemandPlanning.DataStore
{
    public class ConfigurationDataContext : BaseDataContext, IConfigurationDataContext
    {
        public ConfigurationSettings Configuration { get; private set; }

        public ConfigurationDataContext(string cdsId) : base(cdsId)
        {
            try
            {
                LoadConfigurationData();
                BuildConfiguration();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }

        private void LoadConfigurationData()
        {
            var dataStore = new ConfigurationDataStore(CDSID);
            _configurationData = dataStore.ConfigurationGetMany();

        }

        private void BuildConfiguration()
        {
            //Log.Debug(MethodBase.GetCurrentMethod().Name);

            Configuration = new ConfigurationSettings();
            foreach (var setting in _configurationData)
            {
                //Log.Debug(string.Format("{0}:{1}:{2}", setting.ConfigurationKey, setting.Value, setting.DataType));
                switch (setting.DataType.ToLower())
                {
                    case "system.string":
                        Configuration.AddStringSetting(setting.ConfigurationKey, setting.Value);
                        break;
                    case "system.int32":
                        Configuration.AddIntegerSetting(setting.ConfigurationKey, setting.Value);
                        break;
                    case "system.boolean":
                        Configuration.AddBooleanSetting(setting.ConfigurationKey, setting.Value);
                        break;
                }
            }
        }

        #region "Private members"

        private IEnumerable<ConfigurationItem> _configurationData;
       
        #endregion
    }
}
