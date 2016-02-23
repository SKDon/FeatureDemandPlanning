//using FeatureDemandPlanning.Bindings;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using Ninject;

namespace FeatureDemandPlanning.DataStore
{
    public class DataContext : BaseDataContext, IDataContext
    {
        public DataContext(string cdsId) : base(cdsId)
        {
        }

        public string CurrentCDSId { get { return CDSID; } }
        public IDbHelper GetHelper() { return new DbHelperNonSingleton(); }

        [Inject]
        public IConfigurationDataContext Configuration { get; set; }
        [Inject]
        public IEmailDataContext Email { get; set; }
        [Inject]
        public IUserDataContext User { get; set; }
        [Inject]
        public IDocumentDataContext Document { get; set; }
        [Inject]
        public IVehicleDataContext Vehicle { get; set; }
        [Inject]
        public IImportDataContext Import { get; set; }
        [Inject]
        public IMarketDataContext Market { get; set; }
        [Inject]
        public ITakeRateDataContext TakeRate { get; set; }
        [Inject]
        public IReferenceDataContext References { get; set; }
        [Inject]
        public INewsDataContext News { get; set; }

        //public ConfigurationSettings ConfigurationSettings { get { return _configurationContext.Configuration; } }

        public ConfigurationSettings ConfigurationSettings
        {
            get
            {
                return Configuration == null ? null : Configuration.Configuration;
            }
        }
    }
}
