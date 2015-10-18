using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IDataContext
    {
        IDbHelper GetHelper();
        IConfigurationDataContext Configuration { get;}
        IEmailDataContext Email { get; }
        IUserDataContext User { get; }
        IDocumentDataContext Document { get; }
        IVehicleDataContext Vehicle { get; }
        IForecastDataContext Forecast { get; }
        IImportDataContext Import { get; }
        IMarketDataContext Market { get; }
        IVolumeDataContext Volume { get; }
        IReferenceDataContext References { get; }

        dynamic ConfigurationSettings { get; }
    }
}
