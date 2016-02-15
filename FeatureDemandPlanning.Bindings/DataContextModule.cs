using System;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using Ninject.Modules;

namespace FeatureDemandPlanning.Bindings
{
    public class DataContextModule : NinjectModule
    {
        public override void Load()
        {
            Func<string> getCdsId = SecurityHelper.GetAuthenticatedUser;

            Bind<IDataContext>().To<DataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IEmailDataContext>().To<EmailDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IUserDataContext>().To<UserDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IDocumentDataContext>().To<DocumentDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IConfigurationDataContext>().To<ConfigurationDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IVehicleDataContext>().To<VehicleDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IImportDataContext>().To<ImportDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IMarketDataContext>().To<MarketDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<ITakeRateDataContext>().To<TakeRateDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<IReferenceDataContext>().To<ReferenceDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
            Bind<INewsDataContext>().To<NewsDataContext>().WithConstructorArgument("cdsId", context => getCdsId());
        }
    }

   
}
