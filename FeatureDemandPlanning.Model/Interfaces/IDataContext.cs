namespace FeatureDemandPlanning.Model.Interfaces
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
        ITakeRateDataContext TakeRate { get; }
        IReferenceDataContext References { get; }
        INewsDataContext News { get; }

        dynamic ConfigurationSettings { get; }
    }
}
