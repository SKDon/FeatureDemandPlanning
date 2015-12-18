using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Helpers;

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

        private IEmailDataContext _emailContext = null;
        private IUserDataContext _userContext = null;
        private IDocumentDataContext _documentContext = null;
        private IConfigurationDataContext _configurationContext = null;
        private IVehicleDataContext _vehicleContext = null;
        private IForecastDataContext _forecastContext = null;
        private IImportDataContext _importContext = null;
        private IMarketDataContext _marketContext = null;
        private ITakeRateDataContext _volumeContext = null;
        private IReferenceDataContext _referenceDataContext = null;
        private INewsDataContext _newsDataContext = null;
    }
}
