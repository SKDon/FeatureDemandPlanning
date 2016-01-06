using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.DataStore
{
    public class DataContext : BaseDataContext, IDataContext
    {
        public DataContext(string cdsId) : base(cdsId) 
        {
            _emailContext = new EmailDataContext(cdsId);
            _userContext = new UserDataContext(cdsId);
            _documentContext = new DocumentDataContext(cdsId);
            _configurationContext = new ConfigurationDataContext(cdsId);
            _vehicleContext = new VehicleDataContext(cdsId);
            _forecastContext = new ForecastDataContext(cdsId);
            _importContext = new ImportDataContext(cdsId);
            _marketContext = new MarketDataContext(cdsId);
            _volumeContext = new TakeRateDataContext(cdsId);
            _referenceDataContext = new ReferenceDataContext("system");
            _newsDataContext = new NewsDataContext(cdsId);
        }

        public IDbHelper GetHelper() { return new DbHelperNonSingleton(); }

        public IConfigurationDataContext Configuration { get { return _configurationContext; } }
        public IEmailDataContext Email { get { return _emailContext; } }
        public IUserDataContext User { get { return _userContext;  } }
        public IDocumentDataContext Document { get { return _documentContext; } }
        public IVehicleDataContext Vehicle { get { return _vehicleContext; } }
        public IForecastDataContext Forecast { get { return _forecastContext; } }
        public IImportDataContext Import { get { return _importContext; } }
        public IMarketDataContext Market { get { return _marketContext; } }
        public ITakeRateDataContext TakeRate { get { return _volumeContext; } }
        public IReferenceDataContext References { get { return _referenceDataContext; } }
        public INewsDataContext News { get { return _newsDataContext; } }

        public dynamic ConfigurationSettings { get { return _configurationContext.Configuration; } }

        private readonly IEmailDataContext _emailContext;
        private readonly IUserDataContext _userContext;
        private readonly IDocumentDataContext _documentContext;
        private readonly IConfigurationDataContext _configurationContext;
        private readonly IVehicleDataContext _vehicleContext;
        private readonly IForecastDataContext _forecastContext;
        private readonly IImportDataContext _importContext;
        private readonly IMarketDataContext _marketContext;
        private readonly ITakeRateDataContext _volumeContext;
        private readonly IReferenceDataContext _referenceDataContext;
        private readonly INewsDataContext _newsDataContext;
    }
}
