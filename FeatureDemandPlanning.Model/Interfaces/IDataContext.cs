using Ninject;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IDataContext
    {
        string CurrentCDSId { get; }
        IDbHelper GetHelper();
        IConfigurationDataContext Configuration { get; set;  }
        IEmailDataContext Email { get; set; }
        IUserDataContext User { get; set; }
        [Inject]
        IDocumentDataContext Document { get; set; }
        IVehicleDataContext Vehicle { get; set; }
        IImportDataContext Import { get; set; }
        IMarketDataContext Market { get; set; }
        ITakeRateDataContext TakeRate { get; set; }
        IReferenceDataContext References { get; set; }
        INewsDataContext News { get; set; }

        ConfigurationSettings ConfigurationSettings { get; }
    }
}
